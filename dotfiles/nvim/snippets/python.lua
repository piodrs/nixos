local luasnip = require('luasnip')
local format = require('luasnip.extras.fmt').fmt
local insert = luasnip.insert_node
local repeat_node = require('luasnip.extras').rep
local snippet = luasnip.snippet

return {
    snippet('cog', format([[from discord.ext import commands


class {}(commands.Cog):
    def __init__(self, bot: commands.Bot) -> None:
        self.bot = bot


async def setup(bot: commands.Bot) -> None:
    await bot.add_cog({}(bot))

{}
]], {
        insert(1, 'ExampleCog'),
        repeat_node(1),
        insert(0),
    })),
}
