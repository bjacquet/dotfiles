local wezterm = require 'wezterm';


function bjFontRandom()
  fonts = {
    "Anonymous Pro",
    "Comic Mono",
    "CozetteVector",
    "MesloLGS NF",
    "NovaMono",
    "Victor Mono",
    "iA Writer Mono S",
  }

  return bjTakeOneRandom(fonts)
end


function bjTakeOneRandom(array)
  position = math.random(1, #(array))
  return array[position]
end


return {
    font = wezterm.font(bjFontRandom()),
    font_size = 14,
}
