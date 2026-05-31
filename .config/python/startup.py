import readline, atexit, os

_history = os.path.join(
    os.getenv("XDG_STATE_HOME", os.path.expanduser("~/.local/state")),
    "python", "history"
)
os.makedirs(os.path.dirname(_history), exist_ok=True)
try:
    readline.read_history_file(_history)
except FileNotFoundError:
    pass
atexit.register(readline.write_history_file, _history)
del readline, atexit, os, _history
