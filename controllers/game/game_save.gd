class_name GameSave
extends Node

const FILE_NAME = "user://savegame.save"

class Content:
    var best_time: float
    
    func _init(best_time: float):
        self.best_time = best_time

static func save(best_time: float):
    var save_file = FileAccess.open(FILE_NAME, FileAccess.WRITE)
    var json_string = JSON.stringify({
        "best_time": best_time
    })
    
    save_file.store_line(json_string)

static func load():
    if FileAccess.file_exists(FILE_NAME):
        var save_file = FileAccess.open(FILE_NAME, FileAccess.READ)
        var text = save_file.get_as_text()
        var json_string = JSON.parse_string(text)
        
        return Content.new(json_string["best_time"])
