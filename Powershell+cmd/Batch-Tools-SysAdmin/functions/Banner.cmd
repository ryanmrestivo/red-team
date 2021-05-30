::Banner.cmd

:: Display a string of text in extra large letters, similar to banner printing on a dot matrix printer.
:: This can be useful when you need to read the output from a distance.

:: Maximum string length: 14 characters (CMD)
:: Maximum string length: 21 characters (PowerShell)

::Command Prompt (14)
::T O O  M A N Y
::12345678901234

::PowerShell (21)
::T O O  M A N Y  L E T
::123456789012345678901

:: Compatible characters:
:: 0-9
:: Hyphen "-"
:: Period "."
:: Comma ","
:: At "@"
:: A-Z (Caps only)
:: Space " "

:: Thanks to:
:: https://ss64.com/nt/syntax-banner.html

@ECHO OFF&SETLOCAL
IF [%1] NEQ [] GOTO s_start
ECHO   Syntax  
ECHO       BANNER string
ECHO           Where string is the text or numbers to be displayed
ECHO:
GOTO :EOF
   :s_start
      SET _length=0
	  SET _sentence=%*
	  
	  ::https://ss64.com/nt/syntax-args.html
      ::https://ss64.com/nt/syntax-substring.html
	  SET _first_letter=%_sentence:~0,1%
	  SET _last_letter=%_sentence:~-1%
	  IF [%_first_letter%%_last_letter%] EQU [""] (FOR %%G IN (%_sentence%) DO SET "_sentence=%%~G")
	  
      :: Get the length of the sentence
      SET _substring=%_sentence%
   :s_loop
      IF NOT DEFINED _substring GOTO :s_result
      ::remove the first char from _substring (until it is null)
      SET _substring=%_substring:~1%
      SET /A _length+=1
      GOTO s_loop
      
   :s_result
      SET /A _length-=1
      
      :: Truncate text to fit the window size
      :: assuming average char is 6 digits wide
      FOR /F "tokens=2" %%G IN ('mode ^|find "Columns"') DO SET /A _window=%%G/6
      IF %_length% GTR %_window% SET _length=%_window% 

      :: Step through each digit of the sentence and store in a set of variables
      FOR /L %%G IN (0,1,%_length%) DO CALL :s_build %%G

   :: Now Echo all the variables
   ECHO:
   ECHO:%_1%
   ECHO:%_2%
   ECHO:%_3%
   ECHO:%_4%
   ECHO:%_5%
   ECHO:%_6%
   ECHO:%_7%
   ECHO:
   GOTO :EOF

   :s_build
      :: get the next character
      CALL SET "_digit=%%_sentence:~%1,1%%%"
      :: Add the graphics for this digit to the variables
      IF "%_digit%"==" " (CALL :s_space) ELSE (CALL :s_%_digit%)
   GOTO :EOF
   
   :s_0
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% #  #)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7% ####)
   GOTO :EOF
   
   :s_1
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%  ## )
      (SET _2=%_2%   # )
      (SET _3=%_3%   # )
      (SET _4=%_4%   # )
      (SET _5=%_5%   # )
      (SET _6=%_6%   # )
      (SET _7=%_7% ####)
   GOTO :EOF
   
   :s_2
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2% #  #)
      (SET _3=%_3%    #)
      (SET _4=%_4% ####)
      (SET _5=%_5% #   )
      (SET _6=%_6% #  #)
      (SET _7=%_7% ####)
   GOTO :EOF
   
   :s_3
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2%    #)
      (SET _3=%_3%    #)
      (SET _4=%_4% ####)
      (SET _5=%_5%    #)
      (SET _6=%_6%    #)
      (SET _7=%_7% ####)
   GOTO :EOF
   
   :s_4
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% #  #)
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% ####)
      (SET _5=%_5%    #)
      (SET _6=%_6%    #)
      (SET _7=%_7%    #)
   GOTO :EOF
   
   :s_5
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2% #   )
      (SET _3=%_3% #   )
      (SET _4=%_4% ####)
      (SET _5=%_5%    #)
      (SET _6=%_6% #  #)
      (SET _7=%_7% ####)
   GOTO :EOF
   
   :s_6
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ##  )
      (SET _2=%_2% #   )
      (SET _3=%_3% #   )
      (SET _4=%_4% ####)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7% ####)
   GOTO :EOF
   
   :s_7
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2% #  #)
      (SET _3=%_3%    #)
      (SET _4=%_4%   ##)
      (SET _5=%_5%   # )
      (SET _6=%_6%   # )
      (SET _7=%_7%   # )
   GOTO :EOF
   
   :s_8
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% ####)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7% ####)
   GOTO :EOF
   
   :s_9
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% ####)
      (SET _5=%_5%    #)
      (SET _6=%_6%    #)
      (SET _7=%_7%    #)
   GOTO :EOF
   
   :s_-
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%     )
      (SET _2=%_2%     )
      (SET _3=%_3%     )
      (SET _4=%_4% ####)
      (SET _5=%_5%     )
      (SET _6=%_6%     )
      (SET _7=%_7%     )
   GOTO :EOF
   
   :s_:
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%     )
      (SET _2=%_2%     )
      (SET _3=%_3%  #  )
      (SET _4=%_4%     )
      (SET _5=%_5%  #  )
      (SET _6=%_6%     )
      (SET _7=%_7%     )
   GOTO :EOF
   
   :s_.
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%     )
      (SET _2=%_2%     )
      (SET _3=%_3%     )
      (SET _4=%_4%     )
      (SET _5=%_5%     )
      (SET _6=%_6%     )
      (SET _7=%_7%  #  )
   GOTO :EOF
   
   :s_,
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%     )
      (SET _2=%_2%     )
      (SET _3=%_3%     )
      (SET _4=%_4%     )
      (SET _5=%_5%     )
      (SET _6=%_6%  #  )
      (SET _7=%_7% #   )
   GOTO :EOF
   
   :s_@
   ::  Length = 6
   ::  Pad digits to --->
      (SET _1=%_1%  ### )
      (SET _2=%_2% #   #)
      (SET _3=%_3% # # #)
      (SET _4=%_4% ## ##)
      (SET _5=%_5% # ## )
      (SET _6=%_6% #    )
      (SET _7=%_7%  ### )
   GOTO :EOF
   
   :s_a
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%  ## )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% ####)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7% #  #)
   GOTO :EOF
   
   :s_b
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ### )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% ####)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7% ### )
   GOTO :EOF
   
   :s_c
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%  ## )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #   )
      (SET _4=%_4% #   )
      (SET _5=%_5% #   )
      (SET _6=%_6% #  #)
      (SET _7=%_7%  ## )
   GOTO :EOF
   
   :s_d
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ### )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% #  #)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7% ### )
   GOTO :EOF
   
   :s_e
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2% #   )
      (SET _3=%_3% #   )
      (SET _4=%_4% ### )
      (SET _5=%_5% #   )
      (SET _6=%_6% #   )
      (SET _7=%_7% ####)
   GOTO :EOF
   
   :s_f
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2% #   )
      (SET _3=%_3% #   )
      (SET _4=%_4% ### )
      (SET _5=%_5% #   )
      (SET _6=%_6% #   )
      (SET _7=%_7% #   )
   GOTO :EOF

   :s_g
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%  ## )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #   )
      (SET _4=%_4% #   )
      (SET _5=%_5% # ##)
      (SET _6=%_6% #  #)
      (SET _7=%_7%  ## )
   GOTO :EOF

   :s_h
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% #  #)
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% ####)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7% #  #)
   GOTO :EOF

   :s_i
   ::  Length = 4
   ::  Pad digits to ->
      (SET _1=%_1%  # )
      (SET _2=%_2%  # )
      (SET _3=%_3%  # )
      (SET _4=%_4%  # )
      (SET _5=%_5%  # )
      (SET _6=%_6%  # )
      (SET _7=%_7%  # )
   GOTO :EOF

   :s_j
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ####)
      (SET _2=%_2%   # )
      (SET _3=%_3%   # )
      (SET _4=%_4%   # )
      (SET _5=%_5%   # )
      (SET _6=%_6%   # )
      (SET _7=%_7% ##  )
   GOTO :EOF

   :s_k
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% #   )
      (SET _2=%_2% #  #)
      (SET _3=%_3% # # )
      (SET _4=%_4% ##  )
      (SET _5=%_5% ##  )
      (SET _6=%_6% # # )
      (SET _7=%_7% #  #)
   GOTO :EOF

   :s_l
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% #   )
      (SET _2=%_2% #   )
      (SET _3=%_3% #   )
      (SET _4=%_4% #   )
      (SET _5=%_5% #   )
      (SET _6=%_6% #   )
      (SET _7=%_7% ####)
   GOTO :EOF

   :s_m
   ::  Length = 6
   ::  Pad digits to --->
      (SET _1=%_1% #   #)
      (SET _2=%_2% ## ##)
      (SET _3=%_3% # # #)
      (SET _4=%_4% # # #)
      (SET _5=%_5% #   #)
      (SET _6=%_6% #   #)
      (SET _7=%_7% #   #)
   GOTO :EOF

   :s_n
   ::  Length = 6
   ::  Pad digits to --->
      (SET _1=%_1% #   #)
      (SET _2=%_2% ##  #)
      (SET _3=%_3% ##  #)
      (SET _4=%_4% # # #)
      (SET _5=%_5% #  ##)
      (SET _6=%_6% #  ##)
      (SET _7=%_7% #   #)
   GOTO :EOF

   :s_o
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%  ## )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% #  #)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7%  ## )
   GOTO :EOF

   :s_p
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ### )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% ### )
      (SET _5=%_5% #   )
      (SET _6=%_6% #   )
      (SET _7=%_7% #   )
   GOTO :EOF

   :s_q
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%  ## )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% #  #)
      (SET _5=%_5% #  #)
      (SET _6=%_6% # ##)
      (SET _7=%_7%  # #)
   GOTO :EOF

   :s_r
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% ### )
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% ### )
      (SET _5=%_5% # # )
      (SET _6=%_6% #  #)
      (SET _7=%_7% #  #)
   GOTO :EOF

   :s_s
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1%  ###)
      (SET _2=%_2% #   )
      (SET _3=%_3% #   )
      (SET _4=%_4%  ## )
      (SET _5=%_5%    #)
      (SET _6=%_6%    #)
      (SET _7=%_7% ### )
   GOTO :EOF

   :s_t
   ::  Length = 4
   ::  Pad digits to ->
      (SET _1=%_1% ###)
      (SET _2=%_2%  # )
      (SET _3=%_3%  # )
      (SET _4=%_4%  # )
      (SET _5=%_5%  # )
      (SET _6=%_6%  # )
      (SET _7=%_7%  # )
   GOTO :EOF

   :s_u
   ::  Length = 5
   ::  Pad digits to -->
      (SET _1=%_1% #  #)
      (SET _2=%_2% #  #)
      (SET _3=%_3% #  #)
      (SET _4=%_4% #  #)
      (SET _5=%_5% #  #)
      (SET _6=%_6% #  #)
      (SET _7=%_7%  ## )
   GOTO :EOF

   :s_v
   ::  Length = 6
   ::  Pad digits to --->
      (SET _1=%_1% #   #)
      (SET _2=%_2% #   #)
      (SET _3=%_3% #   #)
      (SET _4=%_4% #   #)
      (SET _5=%_5% #   #)
      (SET _6=%_6%  # # )
      (SET _7=%_7%   #  )
   GOTO :EOF

   :s_w
   ::  Length = 8
   ::  Pad digits to ----->
      (SET _1=%_1% #  #  #)
      (SET _2=%_2% #  #  #)
      (SET _3=%_3% #  #  #)
      (SET _4=%_4% #  #  #)
      (SET _5=%_5% #  #  #)
      (SET _6=%_6% #  #  #)
      (SET _7=%_7%  ## ## )
   GOTO :EOF

   :s_x
   ::  Length = 6
   ::  Pad digits to --->
      (SET _1=%_1%      )
      (SET _2=%_2% #   #)
      (SET _3=%_3%  # # )
      (SET _4=%_4%   #  )
      (SET _5=%_5%   #  )
      (SET _6=%_6%  # # )
      (SET _7=%_7% #   #)
   GOTO :EOF

   :s_y
   ::  Length = 6
   ::  Pad digits to --->
      (SET _1=%_1% #   #)
      (SET _2=%_2%  # # )
      (SET _3=%_3%   #  )
      (SET _4=%_4%   #  )
      (SET _5=%_5%   #  )
      (SET _6=%_6%   #  )
      (SET _7=%_7%   #  )
   GOTO :EOF

   :s_z
   ::  Length = 6
   ::  Pad digits to --->
      (SET _1=%_1% #####)
      (SET _2=%_2%     #)
      (SET _3=%_3%    # )
      (SET _4=%_4%   #  )
      (SET _5=%_5%  #   )
      (SET _6=%_6% #    )
      (SET _7=%_7% #####)
   GOTO :EOF

   :s_space
   ::  Length = 6
   ::  Pad digits to --->
      (SET _1=%_1%      )
      (SET _2=%_2%      )
      (SET _3=%_3%      )
      (SET _4=%_4%      )
      (SET _5=%_5%      )
      (SET _6=%_6%      )
      (SET _7=%_7%      )
   GOTO :EOF
