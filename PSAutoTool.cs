using System;
using System.Text;
using System.Drawing;
using System.Collections.Generic;
using System.Runtime.InteropServices;
namespace PSAutoTool{
    public class Mouse {
        [DllImport("user32.dll")]
        private static extern bool GetCursorPos(out Point lpPoint);
        [DllImport("user32.dll")]
        private static extern bool SetCursorPos(int x, int y);
        public static System.Drawing.Point GetCursorPosition(){
           System.Drawing.Point lpPoint;
           GetCursorPos(out lpPoint);
           return lpPoint;
        }
        public static void SetCursorPosition(int x, int y){
           SetCursorPos(x,y);
        }
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] 
        private static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);

        public static void ClickLeft(){
            mouse_event(0x02, 0, 0, 0, 0);
            mouse_event(0x04, 0, 50, 0, 0);
        }  
        public static void ClickRight(){
            mouse_event(0x08, 0, 0, 0, 0);
            mouse_event(0x10, 0, 50, 0, 0);
        } 
        public static void LeftDown(){
            mouse_event(0x02, 0, 0, 0, 0);
        }  
        public static void RightDown(){
            mouse_event(0x08, 0, 0, 0, 0);
        }  
        public static void LeftUp(){
            mouse_event(0x04, 0, 50, 0, 0);
        }  
        public static void RightUp(){
            mouse_event(0x10, 0, 50, 0, 0);
        }  
    }
    public class Window {
        private delegate bool Win32Callback(IntPtr hwnd, IntPtr lParam);

        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] 
        private static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
                    
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] 
        private static extern int GetWindowText(IntPtr hwnd,StringBuilder lpString, int cch);

        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        private static extern Int32 GetWindowThreadProcessId(IntPtr hWnd,out uint lpdwProcessId);

        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        private static extern Int32 GetWindowTextLength(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] 
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool EnumChildWindows(IntPtr window, EnumWindowProc callback, IntPtr i);

        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] 
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] 
        public static extern int SetForegroundWindow(IntPtr hwnd);

        public static void Maximize(IntPtr hwnd){
            ShowWindowAsync(hwnd,3);
        }
        public static void Minimize(IntPtr hwnd){
            ShowWindowAsync(hwnd,6);
        }
        public static void Hide(IntPtr hwnd){
            ShowWindowAsync(hwnd,0);
        }
        public static void Normalize(IntPtr hwnd){
            ShowWindowAsync(hwnd,1);
        }
        public static String GetTitle(IntPtr hwnd){
            Int32 Length = GetWindowTextLength(hwnd) + 1;
            StringBuilder buffer = new StringBuilder(Length);
            GetWindowText(hwnd,buffer,Length);
            return buffer.ToString();
        }
        public static List<IntPtr> GetRootWindowsOfProcess(int pid)
        {
            List<IntPtr> rootWindows = GetChildWindows(IntPtr.Zero);
            List<IntPtr> dsProcRootWindows = new List<IntPtr>();
            foreach (IntPtr hWnd in rootWindows)
            {
                uint lpdwProcessId;
                GetWindowThreadProcessId(hWnd, out lpdwProcessId);
                if (lpdwProcessId == pid)
                    dsProcRootWindows.Add(hWnd);
            }
            return dsProcRootWindows;
        }
        public static List<IntPtr> GetChildWindows(IntPtr parent)
        {
            List<IntPtr> result = new List<IntPtr>();
            GCHandle listHandle = GCHandle.Alloc(result);
            try
            {
                EnumWindowProc childProc = new EnumWindowProc(EnumWindow);
                EnumChildWindows(parent, childProc,GCHandle.ToIntPtr(listHandle));
            }
            finally
            {
                if (listHandle.IsAllocated)
                    listHandle.Free();
            }
            return result;
        }
        private static bool EnumWindow(IntPtr handle, IntPtr pointer)
        {
            GCHandle gch = GCHandle.FromIntPtr(pointer);
            List<IntPtr> list = gch.Target as List<IntPtr>;
            if (list == null)
            {
                throw new InvalidCastException("GCHandle Target could not be cast as List<IntPtr>");
            }
            list.Add(handle);
            return true;
        }
        private delegate bool EnumWindowProc(IntPtr hWnd, IntPtr parameter);
    }
}