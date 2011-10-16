#import "STBase64.h"

static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation STBase64

+ (NSString *)encode:(NSString *)string {
	unsigned char *inputBuffer = (unsigned char *)[string UTF8String];
    int len = strlen((const char *)inputBuffer);
	int encodedLength = ((((len % 3) + len) / 3) * 4) + 1;
	unsigned char outputBuffer[encodedLength + 1];

	
	NSInteger i, j = 0;
	int remain;
	
	for(i = 0; i < len; i += 3) {
		remain = len - i;
		
		outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) | 
									 ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4): 0)];
		
		if(remain > 1)
			outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)
										 | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];
		else 
			outputBuffer[j++] = '=';
		
		if(remain > 2)
			outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];
		else
			outputBuffer[j++] = '=';			
	}
	
	outputBuffer[j] = '\0';

	return [NSString stringWithUTF8String:(const char *)outputBuffer];
}

@end
