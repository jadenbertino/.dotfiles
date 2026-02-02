## Code Exploration

Before reading multiple files to understand something, ask yourself: 
"Am I trying to *understand* or *modify*?"

**Understand** → Use the explore agent (`@agents/explore.md`). It navigates 
semantically and returns a concise summary with key locations.

**Modify** → Read the specific files you need to change.

The explore agent is cheaper than loading files into context. Use it liberally 
for questions like "where is X", "how does Y work", "what calls Z".

## Tools

Prefer Serena MCP tools over built-in file operations when Serena is available 
and has a relevant tool for the task. Serena provides semantic code navigation 
(go to definition, find references, search symbols) which is more accurate than 
text search for understanding code structure.