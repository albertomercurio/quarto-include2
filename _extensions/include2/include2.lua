return {
  ['include2'] = function(args, kwargs, meta, raw_args, context)
    -- parse "path/to/file.qmd#the-label"
    local input = pandoc.utils.stringify(args[1])
    local filepath, wanted = input:match("(.+)#(.+)")
    if not filepath or not wanted then
      error("include2: expected file.qmd#label")
    end

    -- read the file
    local project = os.getenv("QUARTO_PROJECT_DIR") or "."
    local full = project .. "/" .. filepath
    local fh = io.open(full, "r")
    if not fh then error("cannot open "..full) end
    local content = fh:read("*all")
    fh:close()

    local blocks = quarto.utils.string_to_blocks(content)

    print("include2: blocks", tostring(blocks))

    -- for block in content:gmatch("(```%b{}\n.-\n```)" ) do
    --   -- 4) check for your label‐comment inside:
    --   if block:find("#|%s*label%s*:%s*" .. wanted) then
    --     print("include2: found label", wanted)
    --     -- 5) return it raw, so Quarto reinserts it verbatim
    --     return pandoc.RawBlock("markdown", block)
    --     -- return block
    --     -- return "CIAONE!"
    --   end
    -- end

    for _, blk in ipairs(blocks) do
      if blk.t == "CodeBlock" and blk.text:match("#|%s*label%s*:%s*" .. wanted) then
        return pandoc.Blocks{ blk }
      end
    end

    error("include2: no cell labeled '"..wanted.."' in "..filepath)
  end
}