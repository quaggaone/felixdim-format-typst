-- Pandoc Lua filter to parse date strings into structured components
-- This filter converts date strings like "2025-12-08" into separate year, month, day fields
-- that can be consumed by Typst templates

function Meta(meta)
  if meta.date then
    local date = meta.date
    local year, month, day

    -- Check if date is a string (e.g., "2025-12-08")
    if type(date) == 'string' or pandoc.utils.type(date) == 'Inlines' then
      local date_str = pandoc.utils.stringify(date)

      -- Parse YYYY-MM-DD format
      year, month, day = date_str:match("^(%d%d%d%d)%-(%d%d?)%-(%d%d?)$")

      if not year then
        -- Try YYYY/MM/DD format
        year, month, day = date_str:match("^(%d%d%d%d)/(%d%d?)/(%d%d?)$")
      end

      -- If we successfully parsed the date, create structured table
      if year and month and day then
        -- Convert to numbers to remove leading zeros
        meta.date = {
          year = tonumber(year),
          month = tonumber(month),
          day = tonumber(day)
        }
      end
    end
    -- If date is already a structured table, leave it as-is
  end

  return meta
end
