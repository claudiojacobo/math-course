--- Process an H1 header with class 'centered-title' to inject LaTeX homework counters.
-- Extracts a homework number from the header text, then injects LaTeX code that resets and renumbers exercise, codelisting, and lstlisting counters using that number. It ensures the counters exist before redefining them.
-- @param el (table) A Pandoc header element (level, classes, content, ...)
-- @return (table|nil) A list containing the original header and a RawBlock with LaTeX code, or nil if the header does not match the criteria.

function Header(el)
  if el.level == 1 and el.classes:includes("centered-title") then
    local text = pandoc.utils.stringify(el)
    
    -- Make sure the H1 contains "Homework"
    if string.find(text, "Homework") then
      -- Extract the first number found in the title text
      local hw_num = string.match(text, "%d+")
      
      if hw_num then
        -- Build the raw LaTeX block to inject.
        -- We check if the listing counters exist to prevent compilation errors on assignments that do not contain any code blocks.
        local latex_snippet = string.format([[
\pagestyle{plain}
\setcounter{page}{1}

\setcounter{exercise}{0}
\renewcommand{\theexercise}{%s.\arabic{exercise}}

\makeatletter
\@ifundefined{c@codelisting}{}{
  \setcounter{codelisting}{0}
  \renewcommand{\thecodelisting}{%s.\arabic{codelisting}}
}
\@ifundefined{c@lstlisting}{}{
  \setcounter{lstlisting}{0}
  \renewcommand{\thelstlisting}{%s.\arabic{lstlisting}}
}
\makeatother
]], hw_num, hw_num, hw_num)
        
        -- Return the original header, immediately followed by our auto-generated LaTeX
        return {el, pandoc.RawBlock('latex', latex_snippet)}
      end
    end
  end
end