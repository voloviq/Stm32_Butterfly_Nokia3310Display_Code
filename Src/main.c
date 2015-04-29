/*
	Description:
	Examples software which show work of Nokia 3310 work
	on Stm32 butterfly develboard

	Compiler: Gnu Gcc

	Language: Ansi C

	Ide: Eclipse

	Author: Michał Wołowik

	Date: Rzeszów march 2010r.
*/





// Include needed library
#include "Stm32l_level.h"
#include "Lcd3310.h"
#include "StringsConv.h"






int main(void)
{

	volatile unsigned int i = 0;
	char *temp_tab;
	unsigned char temp_a = 0;
	unsigned char change = 0;


	// Initialize needed peryferial to blinking leds
	Low_Level_Initialize();

	LCD_Init();
	LCD_Clear();



	while (1)
	{

		if(i > 0 && i< 0x4FFFF)
		{
			Led_1(1);
			Led_2(0);

			if(change == 0)
				temp_a++;

			change = 1;

			if(temp_a>99)
				temp_a = 0;
		}
		else if(i >= 0x4FFFF && i < 0x6FFFF)
		{
			Led_1(0);
			Led_2(1);

			if(change == 1)
			{
				temp_tab = Connect_2String_With_Value("",temp_a,"");

				LCD_Clear ();
				LCD_WriteChar('o', 53, 0); // Znak st C
				LCD_WriteChar(temp_tab[0], 5, 0);
				LCD_WriteChar(temp_tab[1], 29, 0);
			}
			change = 0;

		}
		else if(i >= 0x6FFFF)
			i = 0;

		i++;

/*
		if( !Read_Wkup_Button() )
			Led_Pb9_Light(1);
		else
			Led_Pb9_Light(0);

		if( !Read_Tamp_Button() )
			Led_Pb10_Light(1);
		else
			Led_Pb10_Light(0);
			*/
	}

	return 0;
}

