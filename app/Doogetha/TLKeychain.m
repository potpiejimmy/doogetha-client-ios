//
// Keychain.h
//
// Based on code by Michael Mayo at http://overhrd.com/?p=208
//
// Created by Frank Kim on 1/3/11.
//

#import "TLKeychain.h"
#import <Security/Security.h>
#import <Security/SecImportExport.h>
#import <CommonCrypto/CommonDigest.h>

static const UInt8 publicKeyIdentifier[] = "com.doogetha.client.ios.publickey\0";
static const UInt8 privateKeyIdentifier[] = "com.doogetha.client.ios.privatekey\0";

static const unsigned char _encodedRSAEncryptionOID[15] = {
    
    /* Sequence of length 0xd made up of OID followed by NULL */
    0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
    
};

size_t encodeASN1Length(unsigned char * buf, size_t length) {
    
    // encode length in ASN.1 DER format
    if (length < 128) {
        buf[0] = length;
        return 1;
    }
    
    size_t i = (length / 256) + 1;
    buf[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j) {
        buf[i - j] = length & 0xFF;
        length = length >> 8;
    }
    return i + 1;
}

@implementation TLKeychain

+ (void)saveString:(NSString *)value forKey:(NSString *)key {
	NSAssert(key != nil, @"Invalid key");
	NSAssert(value != nil, @"Invalid value");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];

	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
	[query setObject:key forKey:(__bridge id)kSecAttrAccount];
	
	OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
	if (error == errSecSuccess) {
		// update
		NSDictionary *attributesToUpdate = [NSDictionary dictionaryWithObject:[value dataUsingEncoding:NSUTF8StringEncoding] 
																	  forKey:(__bridge id)kSecValueData];
		
		error = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
		NSAssert1(error == errSecSuccess, @"SecItemUpdate failed: %d", error);
	} else if (error == errSecItemNotFound) {
		// insert
		[query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
		
		error = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
		NSAssert1(error == errSecSuccess, @"SecItemAdd failed: %d", error);
	} else {
		NSAssert1(NO, @"SecItemCopyMatching failed: %d", error);
	}
}

+ (NSString *)getStringForKey:(NSString *)key {
	NSAssert(key != nil, @"Invalid key");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];

	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	[query setObject:key forKey:(__bridge id)kSecAttrAccount];

	CFDataRef dataFromKeychain = nil;

	OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&dataFromKeychain);
	NSData* data = (__bridge_transfer NSData*) dataFromKeychain; 
    
	NSString *stringToReturn = nil;
	if (error == errSecSuccess) {
		stringToReturn = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	
	return stringToReturn;
}

+ (void)deleteStringForKey:(NSString *)key {
	NSAssert(key != nil, @"Invalid key");

	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:key forKey:(__bridge id)kSecAttrAccount];
		
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	if (status != errSecSuccess) {
		NSLog(@"SecItemDelete failed: %ld", status);
	}
}

+ (void)generateKeyPair {
    
    OSStatus status = noErr;
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
        
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];
        
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
        
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:2048] forKey:(__bridge id)kSecAttrKeySizeInBits];
        
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
        
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];

    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
        
    status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey);

    if (status) {
        NSLog(@"SecKeyGeneratePair failed.\n");
    }
        
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
}

+ (NSData*)encodedPublicKey
{
    OSStatus status = noErr;
    CFDataRef publicKeyData = NULL;
    
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyData);

    NSData* rawData = (__bridge_transfer NSData*) publicKeyData;
    
    // OK - that gives us the "BITSTRING component of a full DER
    // encoded RSA public key - we now need to build the rest
    
    unsigned char builder[15];
    NSMutableData * encKey = [[NSMutableData alloc] init];
    int bitstringEncLength;
    
    // When we get to the bitstring - how will we encode it?
    if  ([rawData length ] + 1  < 128 )
        bitstringEncLength = 1 ;
    else
        bitstringEncLength = (([rawData length ] +1 ) / 256 ) + 2 ; 
    
    // Overall we have a sequence of a certain length
    builder[0] = 0x30;    // ASN.1 encoding representing a SEQUENCE
    // Build up overall size made up of -
    // size of OID + size of bitstring encoding + size of actual key
    size_t i = sizeof(_encodedRSAEncryptionOID) + 2 + bitstringEncLength + [rawData length];
    size_t j = encodeASN1Length(&builder[1], i);
    [encKey appendBytes:builder length:j +1];
    
    // First part of the sequence is the OID
    [encKey appendBytes:_encodedRSAEncryptionOID length:sizeof(_encodedRSAEncryptionOID)];
    
    // Now add the bitstring
    builder[0] = 0x03;
    j = encodeASN1Length(&builder[1], [rawData length] + 1);
    builder[j+1] = 0x00;
    [encKey appendBytes:builder length:j + 2];
    
    // Now the actual key
    [encKey appendData:rawData];
    
    return encKey;
}

+ (void)sign:(NSData*)data
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    if (CC_SHA1([data bytes], [data length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
    }
}

@end