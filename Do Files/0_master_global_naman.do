***************************************************************************
* Project: India GDP and Night Lights 
* Purpose: Setting Project Directories and setting Globals
* Original Date: January 9th 2019
* Original Author: Vinayak Iyer

* Instruction: This do file should be run first before other do-files
***************************************************************************

*Naman add your paths as well.*

clear all
set more off,perm

// This is the project working folder 
global projdir ""C:\Users\naman\Google Drive\India GDP night lights\""

// Raw Data Folder
global raw "C:\Users\naman\Google Drive\India GDP night lights\Raw Data"

// Folder where the Final Data set is stored
global final "C:\Users\naman\Google Drive\India GDP night lights\Final Data"

// Folder for Tables 
global tables "C:\Users\naman\Google Drive\India GDP night lights\Analysis Output\Tables"

// Folder for Graphs 
global graphs "C:\Users\naman\Google Drive\India GDP night lights\Analysis Output\Graphs"

// Setting Working Directory
cd $projdir

