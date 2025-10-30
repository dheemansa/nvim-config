return {
	{
		"nvim-mini/mini.hipatterns",
		event = { "BufReadPost", "BufNewFile" },
		opts = function()
			local hipatterns = require("mini.hipatterns")
			return {
				highlighters = {
					fixme = { pattern = "%s*()%f[%w]FIXME%f[%W].*", group = "MiniHipatternsFixme" },
					hack = { pattern = "%s*()%f[%w]HACK%f[%W].*", group = "MiniHipatternsHack" },
					todo = { pattern = "%s*()%f[%w]TODO%f[%W].*", group = "MiniHipatternsTodo" },
					note = { pattern = "%s*()%f[%w]NOTE%f[%W].*", group = "MiniHipatternsNote" },

					-- Highlight hex colors
					hex_color = hipatterns.gen_highlighter.hex_color(),

					-- Highlight rgb() colors
					rgb_color = {
						pattern = "rgb%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)",
						group = function(_, match)
							-- Extract RGB values from the match
							local r, g, b = match:match("rgb%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
							r, g, b = tonumber(r), tonumber(g), tonumber(b)

							-- Validate RGB values are in proper range
							if not r or not g or not b or r > 255 or g > 255 or b > 255 then
								return nil
							end

							-- Convert RGB to hex color
							local hex = string.format("#%02x%02x%02x", r, g, b)

							-- Use mini.hipatterns' built-in function to compute the highlight group
							return hipatterns.compute_hex_color_group(hex, "bg")
						end,
					},

					-- Highlight rgba() colors (alpha channel is ignored)
					rgba_color = {
						pattern = "rgba%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*[%d%.]+%s*%)",
						group = function(_, match)
							-- Extract RGB values from the match (ignore alpha)
							local r, g, b = match:match("rgba%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,")
							r, g, b = tonumber(r), tonumber(g), tonumber(b)

							-- Validate RGB values are in proper range
							if not r or not g or not b or r > 255 or g > 255 or b > 255 then
								return nil
							end

							-- Convert RGB to hex color (alpha is ignored)
							local hex = string.format("#%02x%02x%02x", r, g, b)

							-- Use mini.hipatterns' built-in function to compute the highlight group
							return hipatterns.compute_hex_color_group(hex, "bg")
						end,
					},

					-- Highlight hsl() colors
					hsl_color = {
						pattern = "hsl%(%s*[%d%.]+%s*,%s*[%d%.]+%%?%s*,%s*[%d%.]+%%?%s*%)",
						group = function(_, match)
							-- Extract HSL values from the match
							local h, s, l = match:match("hsl%(%s*([%d%.]+)%s*,%s*([%d%.]+)%%?%s*,%s*([%d%.]+)%%?%s*%)")
							h, s, l = tonumber(h), tonumber(s), tonumber(l)

							if not h or not s or not l then
								return nil
							end

							-- Normalize values
							h = h % 360 -- Hue wraps around
							s = s / 100 -- Convert percentage to 0-1
							l = l / 100 -- Convert percentage to 0-1

							-- Clamp values
							if s < 0 or s > 1 or l < 0 or l > 1 then
								return nil
							end

							-- Convert HSL to RGB
							local r, g, b
							if s == 0 then
								-- Achromatic (gray)
								r, g, b = l, l, l
							else
								local function hue_to_rgb(p, q, t)
									if t < 0 then
										t = t + 1
									end
									if t > 1 then
										t = t - 1
									end
									if t < 1 / 6 then
										return p + (q - p) * 6 * t
									end
									if t < 1 / 2 then
										return q
									end
									if t < 2 / 3 then
										return p + (q - p) * (2 / 3 - t) * 6
									end
									return p
								end

								local q = l < 0.5 and l * (1 + s) or l + s - l * s
								local p = 2 * l - q

								r = hue_to_rgb(p, q, h / 360 + 1 / 3)
								g = hue_to_rgb(p, q, h / 360)
								b = hue_to_rgb(p, q, h / 360 - 1 / 3)
							end

							-- Convert to 0-255 range and create hex
							local hex = string.format(
								"#%02x%02x%02x",
								math.floor(r * 255 + 0.5),
								math.floor(g * 255 + 0.5),
								math.floor(b * 255 + 0.5)
							)

							return hipatterns.compute_hex_color_group(hex, "bg")
						end,
					},

					-- Highlight hsla() colors (alpha channel is ignored)
					hsla_color = {
						pattern = "hsla%(%s*[%d%.]+%s*,%s*[%d%.]+%%?%s*,%s*[%d%.]+%%?%s*,%s*[%d%.]+%s*%)",
						group = function(_, match)
							-- Extract HSL values from the match (ignore alpha)
							local h, s, l = match:match("hsla%(%s*([%d%.]+)%s*,%s*([%d%.]+)%%?%s*,%s*([%d%.]+)%%?%s*,")
							h, s, l = tonumber(h), tonumber(s), tonumber(l)

							if not h or not s or not l then
								return nil
							end

							-- Normalize values
							h = h % 360 -- Hue wraps around
							s = s / 100 -- Convert percentage to 0-1
							l = l / 100 -- Convert percentage to 0-1

							-- Clamp values
							if s < 0 or s > 1 or l < 0 or l > 1 then
								return nil
							end

							-- Convert HSL to RGB
							local r, g, b
							if s == 0 then
								-- Achromatic (gray)
								r, g, b = l, l, l
							else
								local function hue_to_rgb(p, q, t)
									if t < 0 then
										t = t + 1
									end
									if t > 1 then
										t = t - 1
									end
									if t < 1 / 6 then
										return p + (q - p) * 6 * t
									end
									if t < 1 / 2 then
										return q
									end
									if t < 2 / 3 then
										return p + (q - p) * (2 / 3 - t) * 6
									end
									return p
								end

								local q = l < 0.5 and l * (1 + s) or l + s - l * s
								local p = 2 * l - q

								r = hue_to_rgb(p, q, h / 360 + 1 / 3)
								g = hue_to_rgb(p, q, h / 360)
								b = hue_to_rgb(p, q, h / 360 - 1 / 3)
							end

							-- Convert to 0-255 range and create hex
							local hex = string.format(
								"#%02x%02x%02x",
								math.floor(r * 255 + 0.5),
								math.floor(g * 255 + 0.5),
								math.floor(b * 255 + 0.5)
							)

							return hipatterns.compute_hex_color_group(hex, "bg")
						end,
					},
				},
			}
		end,
	},
}
