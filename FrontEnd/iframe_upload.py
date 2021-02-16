# -*- coding: utf-8 -*-
"""
Created on Fri Dec 13 22:01:00 2019

@author: admin
"""
import sys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options  

def main():
    file_loc = sys.argv[1]
    print("read file_loc as ", file_loc)
    chrome_options = Options()  
    chrome_options.add_argument("--headless")  
    driver = webdriver.Chrome(r"C:\Users\admin\Downloads\chromedriver_win32\chromedriver", chrome_options=chrome_options)
    driver.get("http://127.0.0.1:4126/")
    bvh_el = driver.find_element_by_id("bvh_animation_frame")
    driver.switch_to.frame(bvh_el)
    file_upload = driver.find_element_by_id("files")
    file_upload.send_keys(file_loc)


if __name__ == '__main__':
    main()