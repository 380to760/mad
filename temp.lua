local col = require 'async.repl'.colorize
local MAD = require 'MAD'
local vids = require 'vids'
local pixels = require 'pixels'
local home = os.getenv('HOME')
local trash = path.join(home,'.Trash')
local desktop  = path.join(home,'Desktop' )

local ifile = '/Users/laeh/Desktop/CX.images/CX.images.canonical/indexes/MLB.csv'
local data = require(ifile)
local ofile = stringx.replace(ifile, '.csv', '.todownload.csv')
local out = {
	label = {},
	filename = {},
}
for i=1, #data.filename do
	table.insert(out.filename, data.filename[i])
	table.insert(out.label, data.label[i])
end
require('csv').save(ofile, out)