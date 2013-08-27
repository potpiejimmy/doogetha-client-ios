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
    0x30, 0x0d,
                0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, /* RSA OID */
                0x05, 0x00 /* NULL */
};
static const unsigned char _encodedSHA1DigestSequence[15] = {
    
    /* Sequence of length 0x21 made up of sequence of OID followed by NULL + 0x04 (octet data) of length 20 */
    0x30, 0x21,
                0x30, 0x09,
                            0x06, 0x05, 0x2b, 0x0e, 0x03, 0x02, 0x1a, /* SHA-1 OID */
                            0x05, 0x00, /* NULL */
                0x04, 0x14  /* octet data of length 20 */
};

size_t calculateASN1LengthFieldSize(size_t length) {
	if (length <= 0x7F)       return 1;
	if (length <= 0xFF)       return 2;
	if (length <= 0xFFFF)     return 3;
	if (length <= 0xFFFFFFFF) return 5;
	return 9;
}

size_t encodeASN1Length(unsigned char * buf, size_t length) {
    
    if (length <= 0x7F) {
        buf[0] = length;
        return 1;
    }
    
    size_t i = calculateASN1LengthFieldSize(length) - 1; // length of length
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
    
    // that is the BITSTRING component of a full DER encoded RSA public key
    // Now build the complete ASN.1 (X509) encoding, that is
    //
    // 0x30 [SEQUENCE]
    // .... [LENGTH OF SEQUENCE]
    // 0x30 [SEQUENCE]
    // 0x0D [LENGTH OF SEQUENCE OID+NULL]
    // 0x06 [OID]
    // 0x09 [LENGTH OF OID]
    // 0x2a864886f70d010101 [RSA OID]
    // 0x0500 [ASN.1 NULL]
    // 0x03 [BITSTRING]
    // .... [LENGTH OF BITSTRING]
    // 0x00 [NO. OF UNUSED BITS]
    // .... [KEY DATA]
    
    unsigned char builder[15];
    NSMutableData * encKey = [[NSMutableData alloc] init];
    int bitstringLengthFieldSize = calculateASN1LengthFieldSize(1/*no. of unused bits*/ + [rawData length]);
    
    // Overall we have a sequence of a certain length
    builder[0] = 0x30;    // ASN.1 encoding representing a SEQUENCE
    // Build up overall size made up of
    // size of OID +
    // 1 byte 0x03 +
    // size of bitstring length field +
    // 1 byte 0x00 no. of unused bits +
    // size of actual key
    size_t i = sizeof(_encodedRSAEncryptionOID) + 1 + bitstringLengthFieldSize + 1 + [rawData length];
    size_t j = encodeASN1Length(&builder[1], i);
    [encKey appendBytes:builder length:j + 1];
    
    // First part of the sequence is the OID
    [encKey appendBytes:_encodedRSAEncryptionOID length:sizeof(_encodedRSAEncryptionOID)];
    
    // Now add the bitstring
    builder[0] = 0x03;
    j = encodeASN1Length(&builder[1], 1 + [rawData length]);
    builder[j + 1] = 0x00; /*no. of unused bits*/
    [encKey appendBytes:builder length:j + 2];
    
    // Now the actual key
    [encKey appendData:rawData];
    
    return encKey;
}

+ (NSData*)signSHA1withRSA:(NSData*)data
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    if (CC_SHA1([data bytes], [data length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */

        // Prefix the SHA-1-value with "3021300906052b0e03021a05000414"
        // to get a complete ASN.1 SEQUENCE with digest algorithm identifier for SHA-1
        NSMutableData* digestData = [[NSMutableData alloc] init];
        [digestData appendBytes:_encodedSHA1DigestSequence length:sizeof(_encodedSHA1DigestSequence)];
        [digestData appendBytes:digest length:sizeof(digest)];
		
        // Next, encrypt the digestData with private key with RSA/ECB/PKCS1Padding
        OSStatus status = noErr;

        size_t cipherBufferSize;
        uint8_t *cipherBuffer;

        SecKeyRef privateKey = NULL;
        NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];

        NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
        [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
        [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
        [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];

        status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);

        //  Allocate a buffer
        cipherBufferSize = SecKeyGetBlockSize(privateKey);
        cipherBuffer = malloc(cipherBufferSize);

        // Encrypt using private key.
        status = SecKeyEncrypt(privateKey, kSecPaddingPKCS1, [digestData bytes], (size_t) [digestData length], cipherBuffer, &cipherBufferSize);
		NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];

        if (privateKey) CFRelease(privateKey);
        free(cipherBuffer);

        return encryptedData;
    }
	return NULL;
}

@end