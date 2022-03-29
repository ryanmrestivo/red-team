//sample1.inc next INCLUDEs sample1.h - demonstrating nested includes :)
#INCLUDE sample1.h

#define IDS_APP_TITLE         "Sample Application"
#define IDS_APP_NAME          "SampleApp"
#define IDS_APP_AUTHOR        "Angus Johnson"

#define RELEASE                 

#if defined(RELEASE)
  #define MAJOR_VERSION         1
  #define MINOR_VERSION         2
  #define RELEASE_NUMBER        3
  //and just showing what's possible ...
  #define BUILD_NUMBER          (40*(5+5)+56)    
#else 
  #define MAJOR_VERSION         0
  #define MINOR_VERSION         0
  #define RELEASE_NUMBER        0
  #define BUILD_NUMBER          0
#endif

//1. concatenating numbers with strings will produce a string variable
//2. to convert a number to a string variable, just concatenate it with an empty string
//3. the compiler will only accept integers (decimal, hex or octal) as numeric values.
#define IDS_DOTTED_VER_NO     MAJOR_VERSION + "." + MINOR_VERSION + "." + RELEASE_NUMBER + "." + BUILD_NUMBER
