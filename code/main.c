volatile unsigned int * const switches = (volatile unsigned int *)0x80000000;

volatile unsigned int * const buttons = (volatile unsigned int *)0x80000004;

volatile unsigned int * const leds = (volatile unsigned int *)0x80000008;

volatile unsigned char * const ja_in = (volatile unsigned char *)0x8000000C;
volatile unsigned char * const ja_out = (volatile unsigned char *)0x8000000D;
volatile unsigned char * const ja_dir = (volatile unsigned char *)0x8000000E;

volatile unsigned char * const jb_in = (volatile unsigned char *)0x80000010;
volatile unsigned char * const jb_out = (volatile unsigned char *)0x80000011;
volatile unsigned char * const jb_dir = (volatile unsigned char *)0x80000012;

volatile unsigned char * const jc_in = (volatile unsigned char *)0x80000014;
volatile unsigned char * const jc_out = (volatile unsigned char *)0x80000015;
volatile unsigned char * const jc_dir = (volatile unsigned char *)0x80000016;

volatile unsigned char * const jd_in = (volatile unsigned char *)0x80000018;
volatile unsigned char * const jd_out = (volatile unsigned char *)0x80000019;
volatile unsigned char * const jd_dir = (volatile unsigned char *)0x8000001A;

int main(void) {
    *ja_dir = 0xFF;

    for (;;) {
        for (unsigned char value = 1; value != 0; value <<= 1) {
            *ja_out = value;
        }
    }
}
