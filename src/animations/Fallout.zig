const std = @import("std");
const Animation = @import("../tui/Animation.zig");
const Cell = @import("../tui/Cell.zig");
const TerminalBuffer = @import("../tui/TerminalBuffer.zig");

const Allocator = std.mem.Allocator;
const Random = std.Random;

pub const FRAME_DELAY: usize = 8;

const VAULT_BOY_IMAGE =
    \\                                         &&&                          
    \\                                     &&&&x::+X&&&                     
    \\                              &&&  &+::;:...::::+$                    
    \\                             &;+$$x......:;::::::;$&                  
    \\                             &:...:++;xxx++XX;::;;:;$&                
    \\                             &$::;X.........:+;..+&;;&&               
    \\                            &X:x+;;.......;x:....;$;:x&               
    \\                             &&:............;...:X;::x&               
    \\                             &+.;&:..+:.:x$+....:x+x;&&               
    \\       &&&&                 &X:.:;.:X:.....;:...;+Xx$&                
    \\     &+..:$                 &X....:$;...........;+;X&                 
    \\     x...;$                 &X.....:+....;.........x&                 
    \\     X...+&                 &$:x$+:...;xxx$+.......;&                 
    \\     $;..;$                  &x:x+;:..:;x++:....:;x&&                 
    \\ &&&$$$X+::+$&               &&+...+xx:........x&&                    
    \\&$.......+$::$&                &x............;&&&&                    
    \\ &;;;++;:.xx.:&$X$$&&&&&&&&&$$$$$&x:.......:+x+..+$$&&                
    \\ &+....::xX..:$x+;;;;++++;;;;;;;+X.:$&Xx+:.+$;..:$xxxxX&&             
    \\ &+::::...:$:X:;x+;;;;;;;;;;;;;;;$:..:xX$X+:...;$XxxxxxxX$&           
    \\  $+:::;+X&;.x.+xxx++;;;;;;;;;;;;+X+........:x$Xxxxxxxxxxxx$&         
    \\  &+.....:$++;;Xxxxxxxxxx++XX;;;;;X+.....X&$Xxxxxxxxxxxxxxxxx$&       
    \\   &&$Xxxxxx+xxxxxxxxXXX$$&&x;;;;;$:....+XxxxxxxxxxxxxxxxxxxxxX&&     
    \\         &&$&&&&&&&&&&     &x;;;;+X.....XXxxxxxxxxxxxxxxxxxxxxxx$&    
    \\                           &x;;;;x+.....&xxxxxxxxX$$XXxxxxxxxxxxx$&   
    \\                           &x;;;;X+....:&xxxxxxxxXXXX&&&$$xxxxxxXX&   
    \\                           &X;;;;$:....;$xxxxxxxxXXX$&  &XxxxxxXX$&   
    \\                           &$;;;;$:....;$xxxxxxxXXXX&& &XxxxxxXXX&    
    \\                            $+;;;$:....;$xxxxxxxXXX$& &XxxxXXXXX&&    
    \\                            $xXx+X;....;$xxxxxxXXXX$&&$xxXXXXXX&&     
    \\                            &+.:;+:....:&xxxxXX$$x+X&&$XXXXXXX&&      
    \\                            &x.....................x&;X$XXXXX&&       
    \\                            &X:....................+x..:+x$&&         
    \\                            &&xXX;..............;x$&X:...++:$&        
    \\                             &x;;+xX$&$$$$$&$$$$XXXX&;...:$;x&        
    \\                             &X;;+xxxxxxxxxxxxXXXXXXX&$XXXX$&         
    \\                             &&;;+xxxxxxxxxxxxXXXXXXX$&&              
    \\                              &;;+xxxxxxxxxxxxXXXXXXXX&&              
    \\                                   xxxxxxxxxxxXXXXX                   
;

const Fallout = @This();

allocator: Allocator,
terminal_buffer: *TerminalBuffer,
frame: usize,
count: usize,
fg: u32,
default_cell: Cell,

pub fn init(allocator: Allocator, terminal_buffer: *TerminalBuffer, fg: u32) !Fallout {
    return .{
        .allocator = allocator,
        .terminal_buffer = terminal_buffer,
        .frame = 3,
        .count = 0,
        .fg = fg,
        .default_cell = .{ .ch = ' ', .fg = fg, .bg = terminal_buffer.bg },
    };
}

pub fn animation(self: *Fallout) Animation {
    return Animation.init(self, deinit, realloc, draw);
}

fn deinit(_: *Fallout) void {}

fn realloc(_: *Fallout) anyerror!void {}

fn draw(self: *Fallout) void {
    const buf_height = self.terminal_buffer.height;
    const buf_width = self.terminal_buffer.width;
    self.count += 1;
    if (self.count > FRAME_DELAY) {
        self.frame += 1;
        if (self.frame > 4) self.frame = 1;
        self.count = 0;
    }

    const image = VAULT_BOY_IMAGE;
    var image_lines_iter = std.mem.splitSequence(u8, image, "\n");

    const center_x = @divFloor(buf_width, 2);
    var y: usize = @divFloor(buf_height, 4);

    while (image_lines_iter.next()) |line| {
        if (y >= buf_height) break;

        const line_length = line.len;
        const start_x = if (line_length < buf_width)
            center_x - @divFloor(line_length, 2)
        else
            0;

        for (line, 0..) |char, i| {
            if (start_x + i >= buf_width) break;
            const cell = Cell{
                .ch = char,
                .fg = self.fg,
                .bg = self.terminal_buffer.bg,
            };
            cell.put(start_x + i, y);
        }

        y += 1;
    }
}
