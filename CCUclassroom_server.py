import pyautogui
from socket import *
import math
import time
import threading

pyautogui.PAUSE = 0.001
pyautogui.FAILSAFE = False
width, height = pyautogui.size()

#thread
class OneClient(threading.Thread):
    def __init__(self,conn,addr):
        threading.Thread.__init__(self)
        self._conn = conn
        self._addr = addr
    def send(self,data):
        try:
            self._conn.sendall(data)
        except socket.error as msg:
            self.close()
    def close(self):
        self._conn.close()
        print('Disconnect by ',self._addr)
    def run(self):
        try:
            FLAG=True
            while(FLAG):
                receiveMes=self._conn.recv(128).decode()
                if receiveMes!="" :
                    #print("raw=",receiveMes)
                    buf=receiveMes.split("X")
                    for command in buf:
                        if(command!=""):
                            #print(command)
                            if command[0]=="R":
                                pyautogui.click(button='right')
                            elif command[0]=="L":
                                pyautogui.click(button='left')
                            elif command[0]=="E":
                                pyautogui.press('enter')
                            elif command[0]=="U":
                                pyautogui.press('pageup')
                            elif command[0]=="D":
                                pyautogui.press('pagedown')
                            elif command[0]=="P":
                                pyautogui.keyDown('ctrlleft')
                                pyautogui.press('l')
                                pyautogui.keyUp('ctrlleft')
                            elif command[0]=="N":
                                pyautogui.keyDown('ctrlleft')
                                pyautogui.press('u')
                                pyautogui.keyUp('ctrlleft')
                            elif command[0]=="M":
                                command_addr=command.split(" ")
                                #print(command_addr)
                                if(len(command_addr)>2):
                                    try:
                                        x=float(command_addr[1])
                                        y=float(command_addr[2])
                                    except ValueError:
                                        #print("value")
                                        pass
                                    else:
                                        pyautogui.moveTo(x*width+(width/2), y*height+(height/2), duration=0.01)
                                else:
                                    #print("short")
                                    pass
                            elif command[0]=="x":
                                self.close()
                                FLAG=False
    
        
        except KeyboardInterrupt:
            self.close()
##

serverName=getfqdn(gethostname())
serverIP=gethostbyname(serverName)
print(serverName)
print(serverIP)
serverPort=12260
serverSocket=socket(AF_INET,SOCK_STREAM)
serverSocket.setsockopt(SOL_SOCKET,SO_REUSEADDR,1)
serverSocket.bind((serverIP,serverPort))
serverSocket.listen(1)
connectionSocket=None
print("Server is on. Ready to receive.")
try:
    while True:
        conn, addr = serverSocket.accept()
        print('Connect by ',addr)
        OneClient(conn,addr).start()
except KeyboardInterrupt:
    serverSocket.close()
    print('Server Down')
