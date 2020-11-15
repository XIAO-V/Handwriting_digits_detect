#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 基于随机计算的神经网络加速器设计
# 上位机，图片发送软件

import tkinter as tk
from tkinter import ttk
from tkinter import scrolledtext    # 导入滚动文本框的模块
from tkinter import filedialog
from tkinter import messagebox
import serial
import serial.tools.list_ports as uart
from PIL import Image, ImageTk
import numpy as np
import os
import windnd


class GUI():
    '''
    translate image to hex code
    '''
    def __init__(self, init_win):
        self.init_win = init_win
    
    
    def set_win(self):
        self.init_win.title('图片传送 V1.0    (By: 芯光)')
        self.init_win.geometry('900x480+480+270')    # 默认位置为(480, 270)
        self.init_win.resizable(0, 0)   # 防止用户调整尺寸
        # self.init_win["bg"] = "grey"
        # self.init_win.attributes("-alpha",0.9)  # 虚化，值越小虚化程度越高
        
        # image area
        self.img_ui = ttk.LabelFrame(self.init_win, text='图片输入', labelanchor="n")
        self.img_ui.place(relx=0.02, rely=0.01, relheight=0.84, relwidth=0.47)
        self.display = tk.Label(self.img_ui, text='将 图 片 拖 动\n\n到 此 处 打 开', font=('宋体', 20), fg='grey')
        self.display.place(relx=0.5, rely=0.49, anchor='center')
        self.init_path = './'
        
        # output area
        self.hex_ui = ttk.LabelFrame(self.init_win, text='数据输出', labelanchor="n")
        self.hex_ui.place(relx=0.51, rely=0.01, relheight=0.84, relwidth=0.47)
        # self.hex_plot = scrolledtext.ScrolledText(self.hex_ui, width=56, height=28, wrap=tk.WORD)
        self.hex_plot = tk.Text(self.hex_ui, width=56, height=28, wrap=tk.WORD)
        self.hex_plot.config(state='disabled')
        self.hex_plot.place(relx=0.5, rely=0.49, anchor='center')
        
        # serial configure
        self.port = tk.StringVar()
        self.com = ttk.Combobox(self.init_win, width=16, textvariable=self.port)
        self.com['values'] = self.__uart()
        self.com.place(relx=0.13, rely=0.89, anchor='w')
        self.com.current(0)
        self.com.config(state='readonly')   # 设为只读模式
        self.speed_v = tk.IntVar()
        self.speed = ttk.Combobox(self.init_win, width=7, textvariable=self.speed_v)
        self.speed['values'] = (9600, 14400, 19200, 38400, 57600, 115200, 128000, 256000, 512000, 1000000)
        self.speed.place(relx=0.36, rely=0.89, anchor='w')
        self.speed.current(5)
        tk.Label(self.init_win, text='端口: ').place(relx=0.13, rely=0.89, anchor='e')
        tk.Label(self.init_win, text='波特率: ').place(relx=0.36, rely=0.89, anchor='e')
        
        # button
        self.reflash = tk.Button(self.init_win, text='刷新', width=4, command=self.__reflash)
        self.reflash.place(relx=0.02, rely=0.89, anchor='w')
        self.ser_open = tk.Button(self.init_win, text='打开串口', width=12, command=self.__open_uart)
        self.ser_open.place(relx=0.51, rely=0.89, anchor='w')
        self.img_open = tk.Button(self.init_win, text='打开图片', width=12, command=self.__click_file)
        self.img_open.place(relx=0.745, rely=0.89, anchor='center')
        self.start = tk.Button(self.init_win, text='开始传送', width=12, command=self.__start)
        self.start.place(relx=0.98, rely=0.89, anchor='e')
        self.org_img = []
        
        # statusbar
        self.statusbar = tk.Label(self.init_win, text=" Tips: 打开或拖放一张图片", bd=1, relief=tk.SUNKEN, anchor=tk.W)
        self.statusbar.place(relx=0, rely=0.94, relheight=0.06, relwidth=1)
        
        windnd.hook_dropfiles(self.img_ui, self.__drag_file)    # 拖拽文件
    
    
    def __open_uart(self):
        if self.ser_open['text']=='打开串口':
            self.com_name = self.port.get()
            if self.com_name=='None':
                messagebox.showinfo(title='提示信息', message='未检测到串口设备！')
                return 0
            if len(self.speed.get())==0:
                messagebox.showinfo(title='提示信息', message='波特率未设置！')
                return 0
            if self.speed_v.get()==0:
                messagebox.showinfo(title='提示信息', message='波特率未设置！')
                return 0
            self.com_name = self.com_name.split()[0]
            self.ser = serial.Serial(self.com_name, self.speed_v.get(), timeout=0.5)
            self.com.config(state='disabled')
            self.speed.config(state='disabled')
            self.ser_open.config(text='关闭串口')
            self.statusbar.config(text=' Tips: 已打开串口 '+self.port.get())
        else:
            self.ser.close()
            self.com.config(state='readonly')
            self.speed.config(state='normal')
            self.ser_open.config(text='打开串口')
            self.statusbar.config(text=' Tips: 已关闭串口 '+self.port.get())
    
    
    def __start(self):
        if len(self.org_img)==0:
            messagebox.showinfo(title='提示信息', message='未输入图片！')
            return 0
        if self.ser_open['text']=='打开串口':
            messagebox.showinfo(title='提示信息', message='未打开串口！')
            return 0
        data = np.insert(self.org_img, 0, 170).tobytes()    # 启动指令 0xAA
        self.ser.write(data)
        self.statusbar.config(text=' Tips: 数据发送完毕！')
    
    
    def __drag_file(self, files):
        self.img_path = files[0].decode('gbk')
        print('打开文件：', self.img_path)
        self.statusbar.config(text=' Tips: 已加载 '+self.img_path)
        self.init_path = os.path.dirname(self.img_path)
        self.__img_open()
    
    
    def __click_file(self):
        filetype = [('Image File', '*.jpg;*.bmp;*.tiff;*.png;*.jpeg;*.tif;*.gif'), ('All Files', '*')]
        self.img_path = filedialog.askopenfilename(title=u'选择图片文件', filetypes=filetype, initialdir=self.init_path)
        if len(self.img_path) == 0:
            return 0
        print('打开文件：', self.img_path)
        self.statusbar.config(text=' Tips: 已加载 '+self.img_path)
        self.init_path = os.path.dirname(self.img_path)
        self.__img_open()
    
    
    def __img_open(self):
        scale = 13
        # digit = Image.open("D:\Database\Python\深度学习入门：基于Python的理论与实现\dataset\test_img\32_3.bmp")
        # self.digit = ImageTk.PhotoImage(digit.resize((280, 280), Image.ANTIALIAS))
        digit = Image.open(self.img_path).convert('L').resize((28, 28), Image.ANTIALIAS)
        self.org_img = np.array(digit).astype(np.uint8)
        big_img = np.repeat(self.org_img, scale).reshape(28, -1)
        big_img = np.repeat(big_img, scale, axis=0)
        big_img = Image.fromarray(big_img, mode='L')
        self.big_img = ImageTk.PhotoImage(big_img)
        self.display.config(image=self.big_img)
        self.text = ''
        for num in self.org_img.reshape(-1):
            # num = int(num)
            self.text += '%-2X' % num
        self.hex_plot.config(state='normal')
        self.hex_plot.delete(1.0, tk.END)
        self.hex_plot.insert(tk.END, self.text)
        self.hex_plot.see(tk.END)
        self.hex_plot.config(state='disabled')
    
    
    def __uart(self):
        uart_list = []
        uart_port = list(uart.comports())
        if len(uart_port)==0:
            uart_list.append('None')
            messagebox.showinfo(title='提示信息', message='未检测到串口设备！')
        else:
            for com in uart_port:
                com_list = list(com)
                uart_list.append(com_list[0]+' '+com_list[1].split(' (COM')[0])
        return uart_list
    
    
    def __reflash(self):
        if self.ser_open['text']=='关闭串口':
            messagebox.showinfo(title='提示信息', message='串口未关闭！')
            return 0
        self.com['values'] = self.__uart()
        if self.port.get() not in self.com['values']:
            self.port.set(self.com['values'][0])
        self.statusbar.config(text=' Tips: 串口列表已刷新！')

def main():
    win = tk.Tk()
    UI = GUI(win)
    UI.set_win()
    win.mainloop()


main()
