# Plague
## Detection Log
1/29/2019 --> ![Eset][1] Eset NOD32 - a variant of Win32/Agent.TMP trojan

 * **Tools** --> OpenURL --> `ShellExecute` changed to `ShellExecuteW`
 * **CmdWorker** --> Execute --> Mine --> String `config.json` moved to Protected String Storage
 * **CmdWorker** --> Execute --> MemExec --> String `MemExec` added to String Table as `bb32d835`
 * **CmdWorker** --> Execute --> DropExec --> String `DropExec` added to String Table as `896bb1db`
 * **CmdWorker** --> Execute --> Download --> String `Download successful.` moved to Protected String Storage

[1]:data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4wETEykzxj7xmQAAAplJREFUOMuFk09IFGEYxn8z37iTtlopomV0yLYUzVLrVKCQhWBGgiARyJIWJhFFHRSUKMyW/iDYqZtdhMoUOts/gy62q0QZthqlieiuUriTzsyOXwd1JAh8Th/v8zzv4eX7KQC0PYCWaxDo9ANlQBGKkoWUXgAUJYaUU0AI6KfpctdaR6H1DiSIDFTxGWc5zePRqN7nw7d1CyIhAQDHtgn/+k3PaBjLioNQ51h28rCdGQBoaY/S3CZ7R0blRuodGZU0t0la2qMAguutfizrTG9tDVV5OWyk3PQ0DmSk82QwmMSR0h8aplnm0TSq8nPd0MuvYzwaeM/4/C9Akp26jcaSo5T6dgNQlZ+LR0os0yzTMJeKqvcXuuWhyZ+U3QpAUhKbdR0UCI2N8+z1AF8e3CYnMwOA6lwf3R+GilQMI8uX7HUXdL95B0DOlhRiD+8R67zH3pRkUODxq7duzpfsBcPI0lg0vEKorjEdicDiH75NTJB5rgGAuYUYOHGmZ2fdnBACFg2vxpIJjuMa0rLBXCI7fSdXTp8k7iwjhIqCQvb2zPVrOnFYMlGJ2zHHMNz5jhQv2Dax2AIXyk/QWFHOTCTKQGiIse8/1vuGAXE7pqGKqfBsJGXNqDl+jPvdT5lkjl219SQnJTISHgchOJKf5y4Iz0ZAFVMquh7qCQ67xiHfHl503KWkuJC40Jg3LYoPFhCo93PxVIWb6wkOg66HNBI39VuOc7ZvMEjV4WIAKg8XU7n6/p/6BoNYqgKJm/pXJnWNUfwNsjc0vOFXfh4alvgbJHWNUQCF85dAT8xAKCsw6R6qC/LxpaYi9FWYTJvw/Dw9Hz9hmdYKTI7Mw1ycUQC42gQdAWi6uYKzQhHwL84whVzFOXCja63zF+qPTA2L7eyKAAAAAElFTkSuQmCC

