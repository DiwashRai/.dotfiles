
local ls = require("luasnip")

local s = ls.snippet
-- local sn = ls.snippet_node
local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node

ls.add_snippets("cpp", {
  s("dbgtmp", {
    t({
      "void dbg_out() { cerr << endl; }",
      "template<typename Head, typename... Tail>",
      "void dbg_out(Head H, Tail... T) { cerr << ' ' << H; dbg_out(T...); }",
      "#define dbg(...) cerr << \"(\" << #__VA_ARGS__ << \"):\", dbg_out(__VA_ARGS__)"
    })
  }),
  s("iosync", {
    t({
      "std::ios_base::sync_with_stdio(false);",
      "std::cin.tie(0);"
    })
  })
})
