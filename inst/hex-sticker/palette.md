# tines hex sticker

The logo is `man/figures/logo.svg` (source) and `man/figures/logo.png`
(rendered at 480 px wide, used in the README and by pkgdown). It is the
**plum** colourway below.

## Chosen palette: plum

| role | colour |
|---|---|
| background | `#5B3A70` |
| border | `#36213F` |
| fork, text, background paths | `#FBF7F0` |
| decision dot | `#F2C14E` |

Font: Avenir Next, weight 800. The PNG has the text rendered in; the SVG
relies on the font being installed.

## Design

- A fork built from paths: the handle splits at a decision dot into three
  equal tines, which curve out and then run parallel.
- The fork sits at 30°, so its handle runs parallel to the hex's upper-left
  and lower-right edges.
- Behind it, a faint pattern of forking paths (18% opacity).
- A soft drop shadow under the fork.

## The other colourways considered

See `colourways.png` for all six side by side; each has a source SVG here.

| file | background | border | fork and text | dot |
|---|---|---|---|---|
| `teal.svg` | `#1F7A78` | `#124846` | `#FBF7F0` | `#F2785C` |
| `navy.svg` | `#1D2D50` | `#0F1A30` | `#FBF7F0` | `#F2B544` |
| `orange.svg` | `#D9622B` | `#8E3A14` | `#FBF7F0` | `#1D2D50` |
| `plum.svg` | `#5B3A70` | `#36213F` | `#FBF7F0` | `#F2C14E` |
| `light.svg` | `#F4EFEA` | `#232B2B` | `#232B2B`, text `#5C1D24` | `#B8323E` |
| `blue.svg` | `#3A7BD5` | `#1F4F94` | `#FFFFFF` | `#F7A62B` |

## Re-rendering

```r
rsvg::rsvg_png("man/figures/logo.svg", "man/figures/logo.png", width = 480)
```
