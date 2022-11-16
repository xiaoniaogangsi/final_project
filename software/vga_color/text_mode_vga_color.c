/*
 * text_mode_vga_color.c
 * Minimal driver for text mode VGA support
 * This is for Week 2, with color support
 *
 *  Created on: Oct 25, 2021
 *      Author: zuofu
 */

#include <system.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alt_types.h>
#include "text_mode_vga_color.h"

void textVGAColorClr()
{
	for (int i = 0; i<(ROWS*COLUMNS) * 2; i++)
	{
		vga_ctrl->VRAM[i] = 0x00;
	}
}

void textVGADrawColorText(char* str, int x, int y, alt_u8 background, alt_u8 foreground)
{
	int i = 0;
	while (str[i]!=0)
	{
		vga_ctrl->VRAM[(y*COLUMNS + x + i) * 2] = foreground << 4 | background;
		vga_ctrl->VRAM[(y*COLUMNS + x + i) * 2 + 1] = str[i];
		i++;
	}
}

void setColorPalette (alt_u8 color, alt_u8 red, alt_u8 green, alt_u8 blue)
{
	//fill in this function to set the color palette starting at offset 0x0000 2000 (from base)
	alt_u8 index;
	index = color / 2;
	if (color % 2 == 0)		//Lower bits side
	{
		vga_ctrl->VRAM[0x2000 + 4*index] = (blue << 1) | (green << 5);
		vga_ctrl->VRAM[0x2001 + 4*index] &= 0xE0; 	//Zero the lower 5 bits first.
		vga_ctrl->VRAM[0x2001 + 4*index] |= (green >> 3) | (red << 1);
	}else{					//Higher bits side
		vga_ctrl->VRAM[0x2001 + 4*index] &= 0x1F;	//Zero the higher 3 bits first.
		vga_ctrl->VRAM[0x2001 + 4*index] |= (blue << 5);
		vga_ctrl->VRAM[0x2002 + 4*index] = (blue >> 3) | (green << 1) | (red <<5);
		vga_ctrl->VRAM[0x2003 + 4*index] = (red >> 3);
	}
}


void textVGAColorScreenSaver()
{
	//This is the function you call for your week 2 demo
	char color_string[80];
    int fg, bg, x, y;
	textVGAColorClr();
	//initialize palette
	for (int i = 0; i < 16; i++)
	{
		setColorPalette (i, colors[i].red, colors[i].green, colors[i].blue);
	}
	while (1)
	{
		fg = rand() % 16;
		bg = rand() % 16;
		while (fg == bg)
		{
			fg = rand() % 16;
			bg = rand() % 16;
		}
		sprintf(color_string, "Drawing %s text with %s background", colors[fg].name, colors[bg].name);
		x = rand() % (80-strlen(color_string));
		y = rand() % 30;
		textVGADrawColorText (color_string, x, y, bg, fg);
		usleep (100000);
	}
}
