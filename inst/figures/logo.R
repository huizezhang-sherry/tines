library(hexSticker)
library(showtext)

font_add_google("Comic Relief", "Comic")


sticker(imgurl, package="tines",
        p_size=20, s_x=1.3, s_y=.5, s_width=.6,
        h_fill = "#1B3622", # hex fill
        h_color = "#D4AF37", # hex border
        p_color = "#F4EFEA", # text color
        filename="inst/figures/imgfile.png", p_family = "Comic")


# 1. Add your chosen font (e.g., "Montserrat" or "Space Grotesk")
font_add_google("Fredoka", "my_font")
showtext_auto()

# 2. Define your colors
bg_color <- "#F4EFEA" # Aged Parchment
border_color <- "#232B2B" # Deep Charcoal
text_color <- "#5C1D24" # Oxblood Red

imgurl <- file.choose()
sticker(subplot = imgurl,
        package = "tines",
        p_x = 1,
        p_y = 0.6,
        p_size = 25,
        p_family = "my_font",
        p_color = text_color,
        #p_fontface = "bold",
        h_fill = bg_color,
        h_color = border_color,
        s_x = 0.5,       # Fork X position
        s_y = 1,     # Fork Y position
        s_width = 0.9, # Fork size
        filename="inst/figures/imgfile.png")
