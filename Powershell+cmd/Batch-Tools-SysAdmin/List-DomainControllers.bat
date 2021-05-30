
@ECHO %~nx0
@ECHO:
@ECHO List Domain Controllers (DCs) in domain.
@ECHO:

@SET /P "_DOMAIN_NAME=Enter domain name: "

nltest.exe /DCLIST:%_DOMAIN_NAME%

@ECHO:
@PAUSE
@EXIT /B
