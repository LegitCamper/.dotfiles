# python file to control window management
from sys import argv
from pyvda import AppView, get_apps_by_z_order, VirtualDesktop, get_virtual_desktops
import time

# Gets the name of the current workspace
Current_Desktop = VirtualDesktop.current()
if argv[1] == 'GetWorkspaceName':
    with open("C:\\Users\sawye\AutoHotkey\StdOut.txt", 'w') as f:
        f.write(Current_Desktop.name)
        f.close()

# Moves to selected workspace
def Go_to_Workspace(num):
    VirtualDesktop(num).go()

if argv[1] == 'GoToWorkspace1':
    Go_to_Workspace(1)
if argv[1] == 'GoToWorkspace2':
    Go_to_Workspace(2)
if argv[1] == 'GoToWorkspace3':
    Go_to_Workspace(3)
if argv[1] == 'GoToWorkspace4':
    Go_to_Workspace(4)
if argv[1] == 'GoToWorkspace5':
    Go_to_Workspace(5)
if argv[1] == 'GoToWorkspace6':
    Go_to_Workspace(6)
if argv[1] == 'GoToWorkspace7':
    Go_to_Workspace(7)
if argv[1] == 'GoToWorkspace8':
    Go_to_Workspace(8)
if argv[1] == 'GoToWorkspace9':
    Go_to_Workspace(9)

# Moves window to selected workspace))
def Move_Window_To_Workspace(num):
    current_window = AppView.current()
    target_desktop = VirtualDesktop(num)
    current_window.move(target_desktop)
    Go_to_Workspace(num)
    
if argv[1] == 'MoveWinToWorkspace1':
    Move_Window_To_Workspace(1)
if argv[1] == 'MoveWinToWorkspace2':
    Move_Window_To_Workspace(2)
if argv[1] == 'MoveWinToWorkspace3':
    Move_Window_To_Workspace(3)
if argv[1] == 'MoveWinToWorkspace4':
    Move_Window_To_Workspace(4)
if argv[1] == 'MoveWinToWorkspace5':
    Move_Window_To_Workspace(5)
if argv[1] == 'MoveWinToWorkspace6':
    Move_Window_To_Workspace(6)
if argv[1] == 'MoveWinToWorkspace7':
    Move_Window_To_Workspace(7)
if argv[1] == 'MoveWinToWorkspace8':
    Move_Window_To_Workspace(8)
if argv[1] == 'MoveWinToWorkspace9':
    Move_Window_To_Workspace(9)
    
# Pin windows to all workspaces
if argv[1] == 'PinWindow':
    AppView.current().pin()

# Unpinning windows
if argv[1] == 'UnpinWindow':
    AppView.current().unpin()











