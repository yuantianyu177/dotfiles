vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(args)
    local file = args.file
    if vim.fn.getftype(file) ~= "file" then
      return
    end

    if vim.startswith(vim.fn.getline(1), "#!/") then
      vim.fn.system({ "chmod", "+x", file })
    end
  end,
})
