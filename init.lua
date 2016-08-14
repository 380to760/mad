require 'xlua'
-- killall -9 lua
local json = require 'cjson'
local col = require 'async.repl'.colorize
local tmp = '/tmp/'
local image = require 'image'
local pixels = require 'pixels'
local p = pixels
local desktop  = '~/Desktop' desktop = desktop:gsub('^~', os.getenv('HOME'))
local rickPath = 'assets/images/rick.jpg'
local turrellPath = 'assets/images/rick.jpg'
local rick = pixels.load(rickPath)
local turrell = pixels.load(turrellPath)
-- print(turrell)
local MAD = {}

--[[

local dims = #img
local w, h = dims[3], dims[2]
local ok,img = pcall(pixels.load, file, {
minSize = math.min(tileWidth,tileHeight),
type = 'float',
channels = 3,
})
]]

MAD.extensions = {
   videos = {
      ".mkv",
      ".gif",
      ".avi",
      ".mov",
      ".qt",
      ".yuv",
      ".mp4",
      ".tsv",
      ".m4v",
      ".mpg",
      ".mpeg",
   },
   images = {
      ".jpg",
      ".jpeg",
      ".png",
      ".dng",
   },
}

MAD.fs = {
   images_canons_filename2originalPath = '/Users/laeh/Dropbox/_/Indexes/images/canonsFilenames2originalPath.th',
   -- uids = '/Users/laeh/Dropbox/_/Indexes/uids.th',
   uids = '/Users/laeh/mad/380to760_uids.th',
   uid2original = '/Users/laeh/Dropbox/_/Indexes/uid2original.th',
   macbookpro15 = '/Users/laeh/Dropbox/_/assets/images/macbook.th',
}
MAD.dimensions = {
   imac = {
      width = 2560,
      height = 1440,
   },
   macbookProRetina = {
      width = 2880,
      height = 1800,
   },
   macbookAir = {
      width = 1440,
      height = 900,
   },
}
MAD.patch = {
   stuff = {
      name        = "stuff",
      gridSize    = 50,
      patches     = {1,50, 2451, 2500},
      hue         = {0,1},
      light       = {.95,1},
      saturation  = {0,1},
   },
   grass = {
      name        = "grasse",
      gridSize    = 50,
      patches     = {2451, 2500},
      hue         = {68/360,150/360},
      light       = {.1,1},
      saturation  = {.1,1},
   },
   dark = {
      name        = "sky",
      gridSize    = 10,
      patches     = {1,2,3,4,5,6,7,8,9,10},
      hue         = {0,1},
      light       = {0,.2},
      saturation  = {0,1},
   },
   court = {
      name        = "court",
      gridSize    = 10,
      patches     = {91,99},
      hue         = {25/360,62/360},
      light       = {.3,1},
      saturation  = {.3,1},
   }
}
   -- torch.save(training.fs.id2hue_fresh, id2hue_fresh)

MAD.file = {}
function MAD.file.isvid(file)
   file = string.lower(file)
   local is = false
   for _, ext in ipairs(MAD.extensions.videos) do
      if string.find(file, ext) then
         is = true
         if is then break end
      end
   end
   return is
end
function MAD.file.isimg(file)
   file = string.lower(file)
   local is = false
   for _, ext in ipairs(MAD.extensions.images) do
      if string.find(file, ext) then
         is = true
         if is then break end
      end
   end
   return is
end
function MAD.csv2infos(opt)
   -- https://help.github.com/articles/associating-text-editors-with-git/
   -- /tmp/
   -- ~/workspace/source/cortex-core/sandbox
   opt = opt or {}
   local ifile = opt.ifile or error('!!ifile')
   local ofile = opt.ofile or stringx.replace(ifile, '.csv','.txt')
   local odir = opt.odir or path.join(tmp, 'csv2infos.'..path.basename(ifile))
   dir.makepath(odir)
   local fs = {}
   fs.label2filenames = path.join(odir,'fs.label2filenames.th')
   fs.label2count = path.join(odir,'fs.label2count.th')
   fs.infos = path.join(odir,'fs.info.txt')

   -- labe2filenames & labe2count
   local data = require(ifile)
   local total = #data.filename
   local labe2filenames = {}
   for i=1, total do
      local label = data.label[i]
      local filename = data.filename[i]
      labe2filenames[label] = labe2filenames[label] or {}
      table.insert(labe2filenames[label], filename)
   end 
   torch.save(fs.label2filenames,label2filenames)
   local labe2count = {}
   for label, filenames in pairs(labe2filenames) do
      labe2count[label] = #filenames
   end
   torch.save(fs.label2count,labe2count)

   --[[
   tosort table
   ]]
   local function label2countToToSort()
      local label2count = require(fs.label2count)
      local tosort = {}
      local strings = {}
      for label, count in pairs(require(fs.label2count)) do
         local str = string.format('% 9d',tonumber(count))..'|'..label..'\n'
         table.insert(strings, str)
         table.insert(tosort, {
            label = label,
            count = count
         })
      end
      return tosort
   end
   local tosort = label2countToToSort()
   --[[
   sorting and string saving
   ]]
   local function line2string(number, label)
      return stringx.rjust(label,30)..' -  '..stringx.ljust(tostring(number),9)..'\n'
   end

   local total = 0
   for i=1, #tosort do total = total + tosort[i].count end
   table.insert(tosort, {
      label = 'TOTAL',
      count = total
   })

   local byLabel = {}
   table.sort(tosort, function(a,b) return a.label > b.label end)
   for i=1, #tosort do
      table.insert(byLabel, line2string(tosort[i].count, tosort[i].label))
   end
   byLabel = table.concat(byLabel)

   local byCount = {}
   table.sort(tosort, function(a,b) return a.count > b.count end)
   for i=1, #tosort do
      table.insert(byCount, line2string(tosort[i].count, tosort[i].label))
   end
   byCount = table.concat(byCount)

   local byFrequency = {}
   for i=1, #tosort do
      local frequency = tosort[i].count / total
      frequency = torch.round(frequency * 10000) / 100
      table.insert(byFrequency, line2string(frequency, tosort[i].label))
   end
   byFrequency = table.concat(byFrequency)

   local all = table.concat({byFrequency, '\n\n\n\n', byLabel, '\n\n\n\n', byCount,})
   local file = io.open(fs.infos,'w')
   file:write(all)
   file:close()
   os.execute('open "'..fs.infos..'"')
   print('Saved @'..fs.infos)
end
function MAD.csv2infos(opt)
   -- https://help.github.com/articles/associating-text-editors-with-git/
   -- /tmp/
   -- ~/workspace/source/cortex-core/sandbox
   opt = opt or {}
   local ifile = opt.ifile or error('!!ifile')
   local ofile = opt.ofile or stringx.replace(ifile, '.csv','.txt')
   local odir = opt.odir or path.join(tmp, 'csv2infos.'..path.basename(ifile))
   dir.makepath(odir)
   local fs = {}
   fs.label2filenames = path.join(odir,'fs.label2filenames.th')
   fs.label2count = path.join(odir,'fs.label2count.th')
   fs.infos = path.join(odir,'fs.info.txt')

   -- labe2filenames & labe2count
   local data = require(ifile)
   local total = #data.filename
   local labe2filenames = {}
   for i=1, total do
      local label = data.label[i]
      local filename = data.filename[i]
      labe2filenames[label] = labe2filenames[label] or {}
      table.insert(labe2filenames[label], filename)
   end 
   torch.save(fs.label2filenames,label2filenames)
   local labe2count = {}
   for label, filenames in pairs(labe2filenames) do
      labe2count[label] = #filenames
   end
   torch.save(fs.label2count,labe2count)

   --[[
   tosort table
   ]]
   local function label2countToToSort()
      local label2count = require(fs.label2count)
      local tosort = {}
      local strings = {}
      for label, count in pairs(require(fs.label2count)) do
         local str = string.format('% 9d',tonumber(count))..'|'..label..'\n'
         table.insert(strings, str)
         table.insert(tosort, {
            label = label,
            count = count
         })
      end
      return tosort
   end
   local tosort = label2countToToSort()
   --[[
   sorting and string saving
   ]]
   local function line2string(number, label)
      return stringx.rjust(label,30)..' -  '..stringx.ljust(tostring(number),9)..'\n'
   end

   local total = 0
   for i=1, #tosort do total = total + tosort[i].count end
   table.insert(tosort, {
      label = 'TOTAL',
      count = total
   })

   local byLabel = {}
   table.sort(tosort, function(a,b) return a.label > b.label end)
   for i=1, #tosort do
      table.insert(byLabel, line2string(tosort[i].count, tosort[i].label))
   end
   byLabel = table.concat(byLabel)

   local byCount = {}
   table.sort(tosort, function(a,b) return a.count > b.count end)
   for i=1, #tosort do
      table.insert(byCount, line2string(tosort[i].count, tosort[i].label))
   end
   byCount = table.concat(byCount)

   local byFrequency = {}
   for i=1, #tosort do
      local frequency = tosort[i].count / total
      frequency = torch.round(frequency * 10000) / 100
      table.insert(byFrequency, line2string(frequency, tosort[i].label))
   end
   byFrequency = table.concat(byFrequency)

   local all = table.concat({byFrequency, '\n\n\n\n', byLabel, '\n\n\n\n', byCount,})
   local file = io.open(fs.infos,'w')
   file:write(all)
   file:close()
   os.execute('open "'..fs.infos..'"')
   print('Saved @'..fs.infos)
end
function MAD.d1s2csv(d0,ofile)
   local d1s = dir.getdirectories(d0)   
   local out = {
      filename = {},
      label = {}
   }
   local total = 0
   for i, d1 in ipairs(d1s) do
      local label = path.basename(d1)
      local n = 0
      for file in dir.dirtree(d1) do
         if string.find(file, '.ts') then
            local filename = path.basename(file)
            table.insert(out.filename, filename)
            table.insert(out.label, label)
            total = total + 1
            n = n + 1
         end
      end
   end
   print('total', total)
   require('csv').save(training.fs.csv, out)   
end
function MAD.pairsFile2finfos(ftable)
   local tbl = require(ftable) 
   local nlabel = 0
   local total = 0
   local countsStrings = {}
   for k, v in pairs(tbl) do
      local n = #v
      total = total + n 
      table.insert(countsStrings, stringx.rjust(k, 50)..' '..col.Green(stringx.ljust(tostring(n), 10)))
      nlabel = nlabel + 1
   end
   table.insert(countsStrings, stringx.rjust('Total', 30)..' '..stringx.ljust(tostring(total), 10))
   print(ftable)
   for _, string in ipairs(countsStrings) do
      print(string)
   end
   print('-')
end
function MAD.file2id(file)
   local fname = path.basename(file)
   local id 

   id = stringx.replace(fname, '.jpg','')
   id = stringx.replace(id, '.ts','')
   id = stringx.replace(id, '.mp4','')
   id = stringx.replace(id, '.mv4','')
   id = stringx.replace(id, '.jpeg','')
   return id
end
function MAD.applyZip(pdir)
   local idirs = dir.getdirectories(pdir)
   for _, idir in ipairs(idirs) do
      local name = path.basename(idir)
      local ofile = name..'.zip'
      if not path.exists(ofile) then
         local command = 'cd "'..pdir..'"; zip -r "'..ofile..'" "'..name..'"'
         os.execute(command)
      end
   end
end
function MAD.capitalize(string)
   local capital = string.upper( string.sub(string, 1,1) )
      local rest = string.sub(string, 2)
      local capitalized = capital..rest
   return capitalized
end
function MAD.clementMidFrame(vfile)
   local vireo = require 'libluavireo'
   local getMiddleFrame = function(vid, minSize)
      local ok,res = pcall(function()
         local m = vireo.Media(vid)
         local v = m:videoTrack()
         local length = v:count()
         local mid = torch.ceil(length/2)
         local img = v:image(mid)
         if minSize then
            img = img:size(nil,minSize)
         end
         local res = img:toTensor('byte', 'rgb')
         return res
      end)
      return (ok and res) or nil
   end
end
function MAD.csv2json(opt)
   opt = opt or {}
   local icsv = opt.icsv or error('!! missing input training csv')
   local flabels = opt.flabels or error('!! missing output labels json file')
   local flabel2urls = opt.flabel2urls or error('!! missing output labels json file')
   local blobstore = 'https://ton.atla.twitter.com/ckoia_images/'
   local data = require(icsv)
   local label2urls = {}
   local n = #data.filename
   local hlabels = {}
   for i=1, n do
      local label = data.label[i]
      if not hlabels[label] then
         hlabels[label] = label
      end
      if not label2urls[label] then
         label2urls[label] = {}
      end
      local url = path.join(blobstore, data.filename[i])
      table.insert(label2urls[label],url)
   end
   local labels = {}
   for k, v in pairs(hlabels) do
      table.insert(labels, v)
   end
   local function tbl2json(ofile, tbl)
      local json = require 'cjson'
      local j = json.encode(tbl)
      local f = io.open(ofile, 'w')
      f:write(j)
      f:close()
   end
   tbl2json(flabels, labels)
   tbl2json(flabel2urls, label2urls)
end
function MAD.d1s(d0)
   local d1s = dir.getdirectories(d0)
   return d1s
end
function MAD.d2s(d0)
   local flatD2s = {}
   local d1s = dir.getdirectories(d0)
   for _,d1 in ipairs(d1s) do
      local d2s = dir.getdirectories(d1)
      for _, d2 in ipairs(d2s) do
         table.insert(flatD2s, d2)
      end
   end
   return flatD2s
end
function MAD.d3s(d0)
   local flatD3s = {}
   local d1s = dir.getdirectories(d0)
   for _,d1 in ipairs(d1s) do
      local d2s = dir.getdirectories(d1)
      for _, d2 in ipairs(d2s) do
         local d3s = dir.getdirectories(d2)
         for _, d3 in ipairs(d3s) do
            table.insert(flatD3s, d3)
         end
      end
   end
   return flatD3s
end
function MAD.d1s2csv(idir, ofile)
   local csv = require('csv')
   local ofile = ofile or idir..'.csv'
   local out = {
      label = {},
      filename = {},
   }
   for i,d in ipairs(dir.getdirectories(idir)) do
      local label = paths.basename(d)
      for j,file in ipairs(MAD.dir.images.files(d)) do
         table.insert(out.label, label)
         table.insert(out.filename, path.basename(file))
      end
   end
   -- print(out)
   csv.save(ofile..'.csv', out)
   print('')
   print(col.Magenta('ids from '),  col.Yellow(idir)  )
   print(col.Magenta('saved @  '),  col.Yellow(ofile) )
end
function MAD.dedup(list)
   local h = {}
   for _, v in ipairs(list) do
      if not h[v] then
         -- local p = col._blue(v)
         -- print(p)
         h[v] = v
      end
   end
   local  l = {}
   for k, v in pairs(h) do
      table.insert(l, k)
   end
   -- print(l)
   return l
end
function MAD.flattenTable(tbl, dst)
   --[[ Explain
      le trick
      c'est que les args de la fonction
      soient valides quelques soit le niveau dans la recursion
   ]]
   dst = dst or {}
   for k,v in pairs(tbl) do
      if type(v) == 'table' then
         flatten(v, dst)
      else
         table.insert(dst, v)
      end
   end
   return dst
end
function MAD.isMedia()
   if string.find( tfile,'.dng' ) or
      string.find( tfile,'.mov' ) or
      string.find( tfile,'.cr2' ) or
      string.find( tfile,'.gif' ) or
      string.find( tfile,'.jpg' ) or
      string.find( tfile,'.jpeg') or
      string.find( tfile,'.png' ) or
      string.find( tfile,'.mp4' ) or
      string.find( tfile,'.tif' ) or
      string.find( tfile,'.m4v' ) then
      return true
   end
end
function MAD.moveBigFiles(idir, size)
   local files = MAD.image.files(idir)
   local tbl = {}
   for i,file in ipairs(files) do
      xlua.progress(i, #files)
      local ok,img = pcall(pixels.load, file, {
         type = 'float',
         channels = 3,
      })
      if ok then
         if #img then
            local dims = #img
            local w, h = dims[3], dims[2]
            local long = math.max(w,h)
            local short = math.max(w,h)
            if short > size then
               local name = path.basename(file)
               local odir = idir..'.'..size
               dir.makepath(odir)
               to = path.join(odir, name)
               dir.movefile(file,to)
               print(col.Green(file))
            else
               print(col.Red(file))
            end
         end
      end
   end
end
function MAD.moveFoldersByKeywordDetected(d0, keywordList, od0)
    local od0 = od0 or d0..'.byKeywords'
    dir.makepath(od0)
    local d1s = dir.getdirectories(d0)
    for i, d1 in ipairs(d1s) do
        for j, keyword in ipairs(keywordList) do
            local keywordDir = path.join(od0, keyword)
            dir.makepath(keywordDir)
            local name = path.basename(d1)
            local to = path.join(keywordDir, name)
            if string.find( string.lower(d1), string.lower(keyword:gsub('%s+', '_')) ) then
                local command = 'mv "'..d1..'" "'..to..'"'
                os.execute(command)
                -- dir.movefile(d1, to)
                print(col.Cyan(keyword), name)
            end
        end
    end
end
function MAD.organiseMoments()
   local keywords = {
      'today',
      'entertainment',
      'fun',
      'sport',
      'news'
   }
   local d0 =  '/Users/laeh/Desktop/Moments/results'
   local od0 = d0..'.by'
   dir.makepath(od0)
   local d1s =  dir.getdirectories(d0)
   for i, d1 in ipairs(d1s) do
      local d2s =  dir.getdirectories(d1)
      for i, d2 in ipairs(d2s) do
         for _, keyword in ipairs(keywords) do
            if string.find( string.lower(d2), string.lower(keyword) ) then
               local odir = path.join(od0,keyword)
               local d2name = path.basename(d2)
               dir.makepath(odir)
               dir.movefile(d2,path.join(odir,d2name))
            end
         end
      end
   end
end
function MAD.permute(array)
   -- print(col.blue('MAD.permute(array)'))
   for i = 1, #array do
      local  j = torch.random(i,#array)
      array[i], array[j] = array[j], array[i]
   end
   return array
end
function MAD.range(min,max,step)
   print(col.blue('MAD.range(min,max,step)'))
   local step = step or 1
   local min = min or 1
   local nsteps = max/step
   local range = {}
   for i=min,nsteps do
      range[i]=i*step
   end
   return range
end
function MAD.removeEmpty(idir)
   local command = 'cd "'..idir..'"&&   '
   os.execute(command)
end
function MAD.sample(array)
   print(col.blue('MAD.sample(array)'))
   local rdmidx = torch.random(1, #array)
   return array[torch.random(1, #array)]
end
function MAD.saveMediaDirectoryHSVX(idir,ofile)
   local idir = ds.frames
   local files = MAD.dir.medias.files(idir)
   local nfiles = #files
   local mode, f
   if not path.exists(fs.csv_id2hue) then
      f = io.open(fs.csv_id2hue, 'w')
      local header = 'filename,h,s,v,x\n'
      f:write(header)
      f:close()
   end
   f = io.open(fs.csv_id2hue, 'a')

   -- for i=1,  nfiles do
   for i=1,  1000 do
      local file = files[i]
      local id = path.basename(file)
      local score = MAD.image.score.hsvx(file)
      local line = id..','..score.h..','..score.s..','..score.v..','..score.x'\n'
      f:write(line)
      f:flush()
   end
   f:close()
end
function MAD.saveMidFrameFromChunk(ofile,ifile,minSize)
   local res = pixels.guessFileType(ifile)
   if res then 
      local bname = paths.basename(ifile)
      local savePath = ofile
      -- if paths.filep(savePath) then
      --    return
      -- end
      local ok,contents
      if ifile:find('http') then
         ok,contents = pcall(getHTTP,ifile)
         if not ok then
            print('contents: ', contents)
         end
         if not contents then
            local ext = require('paths').extname(ifile)
            if ext == 'mp4' then
               ifile = ifile:gsub('%.mp4','.ts')
            else
               ifile = ifile:gsub('%.ts','.mp4')
            end
            contents = getHTTP(ifile,offset,length)
         end
      else
         contents = io.open(ifile):read('*all')
      end
      -- libs:
      local vireo = require 'libluavireo'
      local media = vireo.Media(function() return torch.ByteStorage():string(contents) end)
      desc = media:videoTrack()
      local count = desc:count()
      local timescale = desc:timescale()
      local lastVideoTime = desc:image(desc:count()):pts() / timescale
      local firstVideoTime = desc:image(1):pts() / timescale
      local wantedTime = (lastVideoTime + firstVideoTime) * 0.5
      local frame
      for i=2,count do
         local ltime = desc:image(i-1):pts() / timescale
         local ptime = desc:image(i):pts() / timescale
         if ltime <= wantedTime and ptime > wantedTime then
            local image = desc:image(i-1):size(0,minSize)
            frame = image:toTensor('byte','rgb')
            break
         end
      end
      local dims = #frame
      if dims[2] > 0  then 
         pixels.save(savePath, frame)
      end
         -- if savePath then
         --    -- print({savePath, frame})
         --    require('pixels').save(savePath, frame)
         -- end
      -- end
   end
end
function MAD.splitFList(files, nbin)
   local n = #files
   local count = 0
   local s = math.floor(n/nbin)
   local binned = {}
   for i=1, nbin do
      binned[i] = {}
      local filesBin = {}
      local oj = (s*(i-1))
      for j=oj, oj+s do
         count = count + 1
         table.insert(binned[i], files[count])
      end
   end
   return binned
end
function MAD.binList(files, nbin)
   local n = #files
   local count = 0
   local s = math.floor(n/nbin)
   local binned = {}
   for i=1, nbin do
      binned[i] = {}
      local filesBin = {}
      local oj = (s*(i-1))
      for j=oj, oj+s do
         count = count + 1
         table.insert(binned[i], files[count])
      end
   end
   return binned
end
function MAD.tableLength(ftable)
   local table = require(ftable)
   local length = 0
   for k, v in pairs(table) do
      length = length + 1
   end
   return length
end
function MAD.tableLeafsCount(ftable)
   local data = require(ftable)
   local total = 0
   for k, v in pairs(data) do
      total = total + #v
   end
   return total
end
function MAD.timeStamp()
   local date = tostring(os.date())
   date = date:gsub('   ', '-')
   date = date:gsub('  ', '-')
   date = date:gsub(' ', '-')
   date = date:gsub('%/', ':')
   return date
end
function MAD.renameAndChangeType()
   local idir =  '/Users/laeh/Desktop/DataCore/Faces/Files/NoFaces/noFace.GR/o'
   -- local odir = idir..'.PNGs'
   -- dir.makepath(odir)
   local files = MAD.dir.images.files(idir)
   for i, file in ipairs(files) do
      xlua.progress(i, #files)
      local fname = path.basename(file)
      local dname = path.dirname(file)
      local newname = sys.uid()..'.jpg'
      local to = path.join(dname, newname)
      -- if string.find(fname, '.png') then
      --    -- MAD.image.save(pixels.load(file), file:gsub(fname,newname))
      --    dir.movefile(file, path.join(odir,sys.uid()..'.png') )
      -- end
      dir.movefile(file, to)
   end
end
MAD.colors = {}
function MAD.colors.show1()
   print(col['Magenta'](stringx.rjust("Magenta", 40))..col["_magenta"](' ')..col['magenta'](stringx.ljust("magenta", 40)))
   print(col['Yellow'](stringx.rjust("Yellow", 40))..col["_yellow"](' ')..col['yellow'](stringx.ljust("yellow", 40)))
   print(col['Green'](stringx.rjust("Green", 40))..col["_green"](' ')..col['green'](stringx.ljust("green", 40)))
   print(col['Blue'](stringx.rjust("Blue", 40))..col["_blue"](' ')..col['blue'](stringx.ljust("blue", 40)))
   print(col['Cyan'](stringx.rjust("Cyan", 40))..col["_cyan"](' ')..col['cyan'](stringx.ljust("cyan", 40)))
   print( col['Red'](stringx.rjust("Red", 40))..col["_red"](' ')..col['red'](stringx.ljust("red", 40)))
end
function MAD.colors.show2()
   local col = require 'async.repl'.colorize
   local LAP = {}
   function LAP.Red() return col.Red('▓▓') end
   function LAP.Blue() return col.Blue('▓▓') end
   function LAP.Cyan() return col.Cyan('▓▓') end
   function LAP.White() return col.White('▓▓') end
   function LAP.Black() return col.Black('▓▓') end
   function LAP.Green() return col.Green('▓▓') end
   function LAP.Yellow() return col.Yellow('▓▓') end
   function LAP.Magenta() return col.Magenta('▓▓') end
   local colors = {'Red','Blue','Cyan','White','Black','Green','Yellow','Magenta'}
   local idxs = {}
   for i=1, 100 do
      for j=1, #colors do
         table.insert(idxs, j)
      end
   end
   local perm = torch.randperm(#idxs)
   local clock = 0
   for i=1, 5 do
      local str = ''
      for j=1, #colors do
         clock = clock + 1
         local c = idxs[perm[clock]]
         local color = colors[c]
         str = str..LAP[color]()
      end
      print(str)
   end
end
MAD.list = {}
function MAD.list.shuffle(list)
   for i = 1, #list do
      local  j = torch.random(i,#list)
      list[i], list[j] = list[j], list[i]
   end
   return list
end
function MAD.list.sample(list, n)
   local shuffled = MAD.list.shuffle(list)
   local sample = {}
   for i=1, n do
      table.insert(sample, shuffled[i])
   end
   return sample
end
function MAD.list.firstN(list, n)
   local newlist = {}
   for i = 1, n do
      table.insert(newlist, list[i])
   end
   return newlist
end
function MAD.list.huesort(files)
   local tbl = {}
   for i, file in ipairs(files) do
      local ftbl = {
         file = file,
         hue = MAD.image.score.hue(file)
      }
      table.insert(tbl, ftbl)
   end
   table.sort(tbl, function(a,b) return a.hue > b.hue end)
   local otbl = {}
   for i=1, #tbl do
      table.insert(otbl, tbl[i].file)
   end
   -- print(otbl)
   return otbl
end
function MAD.list.split(files, nbin)
   local n = #files
   local count = 0
   local s = math.floor(n/nbin)
   local binned = {}
   for i=1, nbin do
      binned[i] = {}
      local filesBin = {}
      local oj = (s*(i-1))
      for j=oj, oj+s do
         count = count + 1
         table.insert(binned[i], files[count])
      end
   end
   return binned
end
function MAD.list.dedup(list)
   local h = {}
   for _, v in ipairs(list) do
      if not h[v] then
         h[v] = v
      end
   end
   local  l = {}
   for k, v in pairs(h) do
      table.insert(l, k)
   end
   return l
end
MAD.table = {}
function MAD.table.flatten(tbl,res)
   res = res or {}
   for k,v in pairs(tbl) do
      if type(v) == 'table' then
         flatten(v,res)
      else
         table.insert(res,v:lower())
      end
   end
   return res
end
MAD.string = {
   list = {
      sort = {}
   }
}
function MAD.string.sanitize(string)
   return require('cjson').encode(string):gsub('^.',''):gsub('.$','')
end
function MAD.string.pad(string, ncol)
   stringx.ljust(string, ncol)
   stringx.rjust(string, ncol)
end
function MAD.string.list.dedup(list)
   local h = {}
   for _, v in ipairs(list) do
      if not h[v] then
         local p = col._blue(v)
         h[v] = v
      end
   end
   local  l = {}
   for k, v in pairs(h) do
      table.insert(l, k)
   end
   return l
end
function MAD.string.normalize(list)
   local txt = require 'txt'
   local testTweetText = [[
   If an astronaut is murdered in the International Space Station, where does the
   killer stand trial?      @bsoloway reports http://atfp.co/1D9kXbS]]

   local opt = {
      stripMentions = false,
      substitutions = {
         URL = ""
      }
   }
   normalized = txt.tweet.normalize(tweetText, opt)
   return normalized
end
function MAD.string.list.sort.length(list)
   local out = {}
   for _, word in ipairs(list) do
     local o = {
        word = word,
        length = string.len(word)
     }
     table.insert(out, o)
   end

   -- DECREASING
   table.sort(out, function(a,b) return a.length > b.length end)
   local    list = {}
   for i, key in ipairs(out) do
      table.insert(list, key.word)
   end
   return list
end
MAD.uids= {}
function MAD.uids.da (n,id)
   local n = n or 1e6
   local id = id or torch.round(torch.uniform(1,n))
   id = id - 1
   assert(id >= 0 and id < n, 'id must be in [1,n]')
   local vocab = 26
   local charS = 97
   local charE = charS + vocab - 1
   local elts = 1
   local chars = 0
   while true do
      elts = elts * vocab
      chars = chars + 1
      if elts >= n then
         break
      end
   end
   local cs = {}
   while true do
      chars = chars - 1
      local basis = vocab ^ chars
      local c = math.floor(id / basis)
      table.insert(cs, c)
      id = id - c*basis
      if chars == 0 then
         break
      end
   end
   local ccs = {}
   for i,c in ipairs(cs) do
      ccs[i] = string.char(charS + c)
   end
   return table.concat(ccs,'')
end
function MAD.uids.make(n, ofile)
   local n = n or 2000000

   print('Generating uids')
   local p = torch.randperm(n)
   local tbl = {}
   for i=1, n do
      -- xlua.progress(i, n)
      local uid = MAD.uids.da (n,p[i])
      table.insert(tbl, uid)
   end

   -- Shuffle
   print('Shuffle the list to be sure')
   local out = {}
   local rdm = torch.randperm(n)
   for j=1, n do
      -- xlua.progress(j, n)
      local uid = tbl[rdm[j]]
      table.insert(out, uid)
   end
   torch.save(ofile, out)
end
function MAD.uids.getn(n, fuids)
   local uids = require(fuids)
   local fcsv = stringx.replace(fuids, '.th', '.csv')
   local olist = {}
   for i=1, n do
      table.insert(olist, uids[i])
   end
   local uidsLeft = {}
   local left = #uids - n
   for i=n+1, #uids do
      table.insert(uidsLeft, uids[i])
   end
   torch.save(fuids, uidsLeft)
   require('csv').save( fcsv, { uid = uidsLeft } )
   print(col.Red(#uidsLeft), 'uids left')
   return olist
end
function MAD.uids.elias()
   return string.lower(os.tmpname():gsub('/tmp/lua_', ''))
end
function MAD.tojson(file, table)
   local json = require 'cjson'
   local j = json.encode(table)
   local f = io.open(file, 'w')
   f:write(j)
   f:close()
end




MAD.image = {}
function MAD.image.save(img, ofile)
   pixels.save(ofile, img)
end
function MAD.image.crop(inputFile, outputRatio, outputFile)
   -- Load input file:
   local input = pixels.load(inputFile)

   -- Input dims:
   local inputWidth = input:size(3)
   local inputHeight = input:size(2)

   -- Input ratio:
   local inputRatio = inputWidth / inputHeight

   -- Output dims:
   local outputWidth, outputHeight
   if outputRatio >= inputRatio then
      outputWidth = inputWidth
      outputHeight = torch.round(outputWidth / outputRatio)
   else
      outputHeight = inputHeight
      outputWidth = torch.round(outputHeight * outputRatio)
   end

   -- Compute corners:
   local top = torch.floor((inputHeight - outputHeight)/2) + 1
   local left = torch.floor((inputWidth - outputWidth)/2) + 1
   local bottom = top + outputHeight - 1
   local right = left + outputWidth - 1

   -- Crop:
   local output = input[{ {},{top,bottom},{left,right} }]

   -- Save:
   pixels.save(outputFile or inputFile, output)
end
function MAD.image.dims(inputFile)
   local out = {}
   local ok,img = pcall(pixels.load, inputFile, {
      type = 'float',
      channels = 3,
   })
   if ok then
      local img = pixels.load(file)
      local dims = #img
      out.w, out.h = dims[3], dims[2]
   end
   return out
end
MAD.image.transform = {}
MAD.image.transform.color = {}
function MAD.image.transform.color.rotate(img)
   local i = image.rgb2hsl(img)
   local shift = torch.uniform()
   i[1]:apply(function(x) return (x+shift)%1 end)
   return image.hsl2rgb(i)
end
function MAD.image.transform.color.invert(img)
   local img  = img or rick
   return -img +1
end
function MAD.image.transform.color.boost(img,opt)
   local opt = opt or {}
   local mR = opt.mR or torch.uniform(0,1) --0.4
   local mG = opt.mG or torch.uniform(0,1) --0.3
   local mB = opt.mB or torch.uniform(0,1) --0.2
   local img = img or rick
   local i3 = img:clone()

   -- (0) normalize the image energy to be 0 mean:
   i3:add(-i3:mean())

   -- (1) normalize all channels to have unit standard deviation:
   i3:div(i3:std())

   -- (2) boost indivudal channels differently (here we give an orange
   --     boost, to warm up the image):
   i3[1]:mul(mR)
   i3[2]:mul(mG)
   i3[3]:mul(mB)

   -- (3) soft clip the image between 0 and 1
   i3:mul(4):tanh():add(1):div(2)

   return i3
end
function MAD.image.transform.color.bw(img)
   return img:mean(1)
end
function MAD.image.transform.color.TEST()
   local transforms = {'rotate','invert','boost','bw'}
   for i, transform in ipairs(transforms) do
      local ofile = desktop..'/'..'rick_'..transform..'ed.jpg'
      MAD.image.save(MAD.image.transform.color[transform](rick), ofile)
   end
end
MAD.image.transform.shuffle = {}
function MAD.image.transform.shuffle.global(img)
   local img = img or rick
   local channels = img:size(1)
   local height = img:size(2)
   local width = img:size(3)
   local matrix = img:view(channels, width*height)
   local perm = torch.randperm(width*height):long()
   local pixels = matrix:index(2,perm)
   local result = pixels:view(channels, height, width)
   return result
end
function MAD.image.transform.shuffle.binned(img,opt)
   local opt         = opt or {}
   local img         = img or rick
   local infos       = pixels.getFileInfo(img)
   local imgh        = opt.imgh or 1024--img:size(2)
   local imgw        = opt.imgw or 1024--img:size(3)
   local verbose     = opt.verbose or true
   local nw          = opt.nw or 8
   local nh          = opt.nh or 8
   local img         = image.scale(img,imgh,imgw)[{{1,3}}]
   local blockw      = imgw/nw
   local blockh      = imgh/nh
   local imgHSL      = image.rgb2hsv(img)*0.99
   local blocks      = imgHSL:unfold(3,blockw,blockw):unfold(2,blockh,blockh)
   local allBlocks   = blocks:reshape((#blocks)[1],
                                   (#blocks)[2]*(#blocks)[3],
                                   (#blocks)[4]*(#blocks)[5])

   if verbose then
      print(col.Magenta('Bins tensors Dimensions = '))
      -- print(imgw..'*'..imgh..'*'.. nw..'*'..nw..'*'..nh)
   end
   for i = 1, (#allBlocks)[2] do
      xlua.progress(i,(#allBlocks)[2])
      local rdmPositions = torch.randperm((#allBlocks)[3]) --Randomize Bins
      for j = 1, (#allBlocks)[3] do
         allBlocks[{ 1,i,j }] = allBlocks[{ 1,i,rdmPositions[j] }]
         allBlocks[{ 2,i,j }] = allBlocks[{ 2,i,rdmPositions[j] }]
         allBlocks[{ 3,i,j }] = allBlocks[{ 3,i,rdmPositions[j] }]
      end
   end
   img = allBlocks:reshape((#blocks)[1],
                           (#blocks)[2],
                           (#blocks)[3],
                           (#blocks)[4],
                           (#blocks)[5])
   img = image.hsv2rgb(img:transpose(3,4):reshape(3,imgh,imgw))
   if verbose then
      print('Shuffle -> #img=',#img)
      print('Reorganize -> #img=',#img)
   end
   return img
end
function MAD.image.transform.shuffle.colorbin(img,opt)
   local opt = opt or {}
   local img = img or rick
   local imgh = opt.imgh or 1024
   local imgw = opt.imgw or 1024
   local imgc = opt.imgc or 3 print(imgh)
   local imgb = opt.imgb or imgw/16 print(imgw) -- == 16 bins
   local img = image.scale(img,imgh,imgw)[{{1,3}}]
   local img = image.rgb2hsl(img)
   local img = img:reshape(3,imgh*imgw)
   local img = img:transpose(2,1)
   local colors = torch.Tensor(100,3)
   for i = 1, 100 do
      colors[{i}] = img[torch.random(1,imgh*imgw)]
   end
   local nw = imgw / imgb
   local nh = imgh / imgb
   local blockPixelsNo = imgb * imgb
   local totalBlocksNo = nw * nh
   local blocksHSL = torch.Tensor(totalBlocksNo,blockPixelsNo,imgc)
   for i = 1,(#blocksHSL)[1] do
      xlua.progress(i,(#blocksHSL)[1])
      local inHSL   = colors[math.floor(torch.uniform(1,(#colors)[1]+1))]
      local ssclaor = torch.uniform(1,1)
      local lscalor = torch.uniform(1,1)
      for j = 1,(#blocksHSL)[2] do
         blocksHSL[i][j][1] = torch.uniform(.5,1.5)
         blocksHSL[i][j][2] = torch.uniform(.5,1.5)
         blocksHSL[i][j][3] = torch.uniform(.5,1.5)
         blocksHSL[i][j]:cmul(inHSL)
      end
   end
   local img = blocksHSL:transpose(2,3)
                        :transpose(1,2)
                        :reshape(imgc,nw,nh,imgb,imgb)
                        :transpose(3,4)
                        :reshape(3,imgw,imgh)
   local img = image.hsl2rgb(img)
   return img
end
function MAD.image.transform.shuffle.gaussian(img, opt)
   local opt = opt or {}
   local img = img or rick
   local w = img:size(3)
   local h = img:size(2)
   local shortSide = math.min(w,h)
   local maxSpread = math.floor(shortSide/20)
   local minSpread = math.floor(shortSide/60)
   local randomSpread = math.floor(torch.uniform(minSpread,maxSpread))
   local spread = randomSpread

   print {
      w = w,
      h = h,
      shortSide = shortSide,
      maxSpread = maxSpread,
      minSpread = minSpread,
      randomSpread = randomSpread,
   }


   -- clone image:
   local shuffled = img:clone()

   -- geometry:
   -- local width = (#img)[3]
   -- local height = (#img)[2]
   -- local channels ,p= (#img)[1]
   local nPixels = w * h

   -- generate random offsets:
   local offsets_x = torch.FloatTensor(nPixels):normal(0, spread):add(.5):long()
   local offsets_y = torch.FloatTensor(nPixels):normal(0, spread):add(.5):long()

   -- shuffle:
   shuffled.pixels.shuffle(shuffled, offsets_x, offsets_y)

   -- return shuffled:
   return shuffled
end
function MAD.image.transform.shuffle.TEST()
   local transforms = {'global','binned','colorbin','gaussian'}
   for i, transform in ipairs(transforms) do
      local ofile = desktop..'/'..'rick_'..transform..'ed.jpg'
      MAD.image.save(MAD.image.transform.shuffle[transform](rick), ofile)
   end
end
function MAD.image.crop(input, outputRatio, outputFile)
   -- Load input file:
   -- print(inputFile)
   -- local input = pixels.load(inputFile)

   -- Input dims:
   local inputWidth = input:size(3)
   local inputHeight = input:size(2)

   -- Input ratio:
   local inputRatio = inputWidth / inputHeight

   -- Output dims:
   local outputWidth, outputHeight
   if outputRatio >= inputRatio then
      outputWidth = inputWidth
      outputHeight = torch.round(outputWidth / outputRatio)
   else
      outputHeight = inputHeight
      outputWidth = torch.round(outputHeight * outputRatio)
   end

   -- Compute corners:
   local top = torch.floor((inputHeight - outputHeight)/2) + 1
   local left = torch.floor((inputWidth - outputWidth)/2) + 1
   local bottom = top + outputHeight - 1
   local right = left + outputWidth - 1

   -- Crop:
   local output = input[{ {},{top,bottom},{left,right} }]

   return output
   -- Save:
   -- pixels.save(outputFile or inputFile, output)
end
MAD.image.score = {}
function MAD.image.score.hue(ifile)
   local command = './imagetool colors "'..ifile..'" 1'
   local hue = sys.execute(command)
   -- print(command)
   -- print(hue)
   return hue
end
function MAD.image.score.patch(opt)
   opt = opt or {}
   local file = opt.file or error('!!file')
   local grid = opt.grid or error('!!grid')
   local patches = opt.patch or error('!!patch')
   local img = image.scale( pixels.load(file), 128, 128)
   local i = img
   -- Patch
   -- local p = pixels.patches(i,{size=i:size(2)/grid})[{ patch }]
   local p = pixels.patches(i,{size=i:size(2)/grid})
   p = p:index(1, torch.LongTensor(patches))
   p = p:transpose(1,2)
   p = p:contiguous()
   p = p:view(3, -1)
   -- p = p:median(2):squeeze()
   p = p:mean(2):squeeze()

   -- standardDevOfBottomThird = p.patches(i,{size=i:size(2)/3})[{ {7,9} }]:transpose(1,2):contiguous():view(3, -1):std()
   local hsl = image.rgb2hsl( p:view(3,1,1)  ):squeeze()


   function p(string)
      return col.Blue(stringx.rjust(string, 6))
   end
   -- function round(v)
   --    torch.round(v *  100)/100
   -- end
   local h = hsl[1] --round(hsl[1])
   local s = hsl[2] --round(hsl[2])
   local l = hsl[3] --round(hsl[3])
   local score = {
      h = h,
      s = s,
      l = l,
   }
   -- print(p('h'),h,p('s'),s,p('l'),l)
   return score
end
function MAD.image.score.hsvx(ifile)
   local command = './newimagetool colors "'..ifile..'" 1'
   local hue = sys.execute(command)
   local scores = stringx.split(hue)
   local tbl = {}
   tbl.h = scores[1]
   tbl.s = scores[2]
   tbl.v = scores[3]
   tbl.x = scores[4]
   return tbl
end
MAD.dir = {}
function MAD.dir.removeEmpty(idir)
   -- print('MAD.dir.removeEmptyFolders('..idir..')')
   local cd = 'cd "'..idir..'"; '
   local command = 'cd "'..idir..'"&& find . -empty -type d -delete'
   os.execute(command)
end
function MAD.dir.repairDotFuckUp(pdir)
   local idirs = dir.getdirectories(pdir)
   for i, idir in ipairs(idirs) do
      local name = path.basename(idir)
      local newname = string.sub(name, 2)
      print(newname)
      local to = path.join( path.dirname(idir), newname)
      dir.movefile(idir, to)
   end
end
MAD.dir.medias = {}
function MAD.dir.medias.d1sCounts(d0, ofile)
   local counts = {}
   local ofile = ofile or d0..'.txt'
   local labelsSortedStrings = {}
   local d1s = dir.getdirectories(d0)
   for _,d1 in ipairs(d1s) do
      local name = path.basename(d1)
      local files = MAD.dir.medias.files(d1)
      local nfiles = #files
      table.insert(counts, {
         count = nfiles,
         name = name,
      })
   end
   table.sort(counts, function(a,b) return a.count > b.count end)
   local total = 0
   for i, labelInfo in ipairs(counts) do
      total = total + 1
      local label  = stringx.ljust(tostring(labelInfo.name)..' ', 50)
      local count  = stringx.rjust(tostring(labelInfo.count)..' ', 16)
      local string = count..' | '..label..'\n'
      table.insert(labelsSortedStrings, string)
   end
   labelsSortedStrings = table.concat(labelsSortedStrings)

   local file = io.open(ofile,'w')
   file:write(labelsSortedStrings)
   file:close()
   os.execute('open "'..ofile..'"')
end
function MAD.dir.medias.treeCounts(d0, ofile)
   local counts = {}
   local ofile = ofile or d0..'.txt'
   local labelsSortedStrings = {}
   local leafs = MAD.dir.tree(d0)
   for _,d1 in ipairs(leafs) do
      local name = path.basename(d1)
      local files = MAD.dir.medias.files(d1)
      local nfiles = #files
      table.insert(counts, {
         count = nfiles,
         name = name,
      })
   end
   table.sort(counts, function(a,b) return a.count > b.count end)
   local total = 0
   for i, labelInfo in ipairs(counts) do
      total = total + 1
      local label  = stringx.ljust(tostring(labelInfo.name)..' ', 50)
      local count  = stringx.rjust(tostring(labelInfo.count)..' ', 16)
      local string = count..' | '..label..'\n'
      table.insert(labelsSortedStrings, string)
   end
   labelsSortedStrings = table.concat(labelsSortedStrings)

   local file = io.open(ofile,'w')
   file:write(labelsSortedStrings)
   file:close()
   os.execute('open "'..ofile..'"')
end
function MAD.dir.tree(idir,limit)
   local dirs = {}
   local n = 0
   for file in dir.dirtree(idir) do
      if limit then if n > limit then break end end
      local res = pixels.guessFileType(file)
      if res then
         local p = paths.dirname(file)
         if not dirs[p] then
            dirs[p] = 1
            n = n + 1
            local ns = string.format('% 9d',n)
            -- local ps = string.format('% 70d',p)
            io.write('images direcories found',col.Cyan(ns), '\r') io.flush()
            -- io.write(col.Blue('   '..n),' ', col.Cyan(p), ' images directory found\r') io.flush()
         end
      end
   end
   local dirlist = {}
   local n = 0
   for idir, stuff in pairs(dirs) do
      n=n +1
      table.insert(dirlist, idir)
   end
   -- print('Fuck ')
   print('MAD.dirtree("'..idir..'")')
   print(#dirlist..' directories found')
   print(dirlist)
   return dirlist
end
function MAD.dir.flattenApply(pdir)
   local idirs = dir.getdirectories(pdir)
   for i, idir in ipairs(idirs) do
      xlua.progress(i, #idirs)
      MAD.dir.flatten(idir)
   end
end
MAD.dir.medias = {}
function MAD.dir.medias.files(idir, limit)
   opt = opt or {}
   local list = {}
   local n = 0
   for file in dir.dirtree(idir) do
      if limit then
         if n > limit - 1 then
            break
         end
      end
      local res = pixels.guessFileType(file)
      if res then
         n = n + 1
         table.insert(list,file)
         io.write(col.Green(n),' Media \r') io.flush()
      end
      if limit then
         if n > limit then
            break
         end
      end
   end
   print('\n')
   return list
end
function MAD.dir.medias.ids(idir, limit)
   opt = opt or {}
   local list = {}
   local n = 0
   for file in dir.dirtree(idir) do
      if limit then
         if n > limit - 1 then
            break
         end
      end
      local res = pixels.guessFileType(file)
      if res then
         n = n + 1
         local fname = path.basename(file)
         table.insert(list,fname)
         io.write(col.Green(n),' Media \r') io.flush()
      end
      if limit then
         if n > limit then
            break
         end
      end
   end
   print('\n')
   return list
end
function MAD.dir.medias.flatten(idir)
   local files = dir.getallfiles(idir)
   for i, file in ipairs(files) do
      xlua.progress(i, #files)
      dir.movefile( file, path.join( idir, path.basename(file) ) )
   end
   local command = 'cd "'..idir..'"&& find . -empty -type d -delete'
   os.execute(command)
end
function MAD.imagesFilesMean(files, ofile, size)
   local s = size or 1024
   local sum = torch.FloatTensor(3,s,s)
   sum:zero()
   local images = {}
   for i, file in ipairs(files) do
      xlua.progress(i,#files)
      local img = pixels.load(file, {
         minSize = math.min(s,s),
         type = 'byte',
         channels = 3,
      })
      local imgbis = image.scale( pixels.crop(img), s, s)
      local imgbisfloat = imgbis:float()
      sum:add(imgbisfloat)
      img:set()
      imgbis:set()
      imgbisfloat:set()
   end
   sum:div(sum:max())
   pixels.save(ofile, sum)
   sum:set()
end
MAD.dir.images = {}
function MAD.dir.images.bin(pdir,binSize)

   -- Args
   local binSize = binSize or 10000
   -- local extension = extension or '.ts'

   -- Folders
   local idir = pdir..'-TEMP'
   local odir = pdir
   dir.movefile(pdir, idir)
   dir.makepath(odir)

   local files = MAD.dir.images.files(idir)
   -- local files = images_files(idir)
   local s = binSize
   local totalFiles = #files
   local n = math.ceil(totalFiles/s)
   local counter = 0
   local c = 0
   for i=1, n do
      local vmin = (i-1) * s
      local vmax = (i-0) * s
      if i == n then
         s = totalFiles - vmin
         vmax = totalFiles
      end
      local sname = s
      if s == 2000 then sname = '2k' end
      if s == 5000 then sname = '5k' end
      if s == 50000 then sname = '50k' end
      if s == 10000 then sname = '10k' end
      local name = path.basename(pdir)
      local oname = sname..'.'..name..'.'..MAD.uids.elias()
      local obin = odir..'/'..oname dir.makepath(obin)
      for j=1, s do
         xlua.progress(j, s)
         counter = counter + 1
         local file = files[counter]
         local fname = path.basename(file)
         local to = obin..'/'..fname
         dir.movefile(file, to)
      end
   end
   dir.rmtree(idir)
end
function MAD.dir.images.files(idir, limit)
   opt = opt or {}
   local list = {}
   local n = 0
   for file in dir.dirtree(idir) do
      local res = pixels.guessFileType(file)
      if res then
         n = n + 1
         table.insert(list,file)
         io.write(col.Green(n),' Images \r') io.flush()
      end
      if limit then
         if n > limit then
            break
         end
      end
   end
   -- print('\n')
   return list
end
function MAD.dir.images.deleteTosmall(idir)
   for i, ifile in ipairs(images_files(idir)) do
      local img = pixels.load(ifile)
      local dims = #img
      -- print(dims)
      local w = dims[2]
      local h = dims[3]
      print(w,h)
      if math.min(h,w) < 256 then
         print(col.Red('tosmall'), ifile)
         local command = 'rm "'..ifile..'"'
         os.execute(command)
      else
         print(col.Cyan('OK'), ifile)
      end
   end
end
function MAD.dir.images.moveWithClassificationScores()
   local col = require 'async.repl'.colorize
   local csv = require('csv')

   function moveWithScores()
      local scores_8c = require('/Users/laeh/Desktop/nsfa-images/images/nolabel/8c.tsv')
      local scores_xx = require('/Users/laeh/Desktop/nsfa-images/images/nolabel/xx.tsv')
      local filenames = scores_8c.filename
      local n = #filenames
      local root = '/Users/laeh/Desktop/nsfa-images/images'
      local labels = {
         'AN',
         'CO',
         'FD',
         'GR',
         'HU',
         'IN',
         'NA',
         'ST'
      }
      local odir = {}
      odir['XX'] = path.join(root,'XX') dir.makepath(odir['XX'])
      odir['AN'] = path.join(root,'AN') dir.makepath(odir['AN'])
      odir['CO'] = path.join(root,'CO') dir.makepath(odir['CO'])
      odir['FD'] = path.join(root,'FD') dir.makepath(odir['FD'])
      odir['GR'] = path.join(root,'GR') dir.makepath(odir['GR'])
      odir['HU'] = path.join(root,'HU') dir.makepath(odir['HU'])
      odir['IN'] = path.join(root,'IN') dir.makepath(odir['IN'])
      odir['NA'] = path.join(root,'NA') dir.makepath(odir['NA'])
      odir['ST'] = path.join(root,'ST') dir.makepath(odir['ST'])


      for i=1, n do
         local to
         local fname = filenames[i]
         local from = path.join(root,'nolabel', fname)
         if tonumber(scores_xx.XX[i]) > .3 then
            to = path.join(odir['XX'], fname)
            print('XX')
            dir.movefile(from, to)
         else
            local probas = {}
            for _, label in ipairs(labels) do
               local proba = tonumber(scores_8c[label][i])
               local tbl = {
                  label = label,
                  proba = proba,
               }
               table.insert(probas, tbl)
            end
            table.sort(probas, function(a,b) return a.proba > b.proba end)
            local winlabel = probas[1].label
            print(winlabel)
            to = path.join(odir[winlabel], fname)
            dir.movefile(from, to)
         end
      end
   end

   function p(string, value)
      print( stringx.rjust(string, 30), col.Blue(value))
   end


   for _, idir in ipairs(dir.getdirectories('/Users/laeh/Desktop/nsfa-images/images')) do
      local files = dir.getallfiles(idir, '.jpg')
      p(path.basename(idir), #files)
   end
end
function MAD.dir.images.moveWithPatchesScored(idir, opt)
   local gridSize    = opt.gridSize    or error('!!patches')
   local name        = opt.name        or error('!!name')
   local patches     = opt.patches     or error('!!patches')
   local saturation  = opt.saturation  or error('!!saturation')
   local light       = opt.light       or error('!!light')
   local hue         = opt.hue         or error('!!hue')


   local hmin,hmax = hue[1],hue[2]
   local smin,smax = saturation[1],saturation[2]
   local lmin,lmax = light[1],light[2]

   local odir = idir..'.'..name
   dir.makepath(odir)
   local files = MAD.dir.images.files(idir)
   local nfiles = #files
   local counter = 0
   local movedCounter = 0
   for i, file in ipairs(files) do
      local name = path.basename(file)

      local str = {
         total = {
            name = col.Red(stringx.rjust(' -- total: ',13)),
            io = col.Red(stringx.ljust(tostring(nfiles)..' ', 7)),
         },
         moved = {
            name = col.Green(stringx.rjust(' -- moved: ',13)),
            io = col.Green(stringx.ljust(tostring(movedCounter)..' ', 7)),
         },

         processed = {
            name = col.Yellow(stringx.rjust(' -- processed: ',13)),
            io = col.Yellow(stringx.ljust(tostring(i)..' ', 7)),
         }
      }
      local score = MAD.image.score.patch({
         file = file,
         grid = gridSize,
         patch = patches,
      })
      if score.h >= hmin  and score.h <= hmax and
         score.s >= smin  and score.s <= smax and
         score.l >= lmin  and score.l <= lmax
      then
         counter = counter + 1
         -- test = test + 1
         local name = path.basename(file)
         local dname = path.dirname(file)
         dname = dname:gsub(idir,'')
         local odir1 = odir..dname
         -- print(odir1)
         dir.makepath(odir1)
         local dest = path.join(odir1, name)
         movedCounter = movedCounter + 1
         dir.movefile( file, dest )
         io.write(
            str.processed.name,str.processed.io,
            str.total.name,str.total.io,
            str.moved.name,str.moved.io,
            ' \r'
         )
      end
   end
end
function MAD.dir.images.saveHues(ofile, idir)
   print(col._blue('img.hue()'))
   local hashedHues
   if path.exists(ofile) then
      hashedHues = require(ofile)
   else
      hashedHues = {}
   end
   local limit = false
   local n = 0
   -- local h = {}
   for file in dir.dirtree(idir) do
      local res = pixels.guessFileType(file)
      if res then
         n = n + 1
         local frameName = path.basename(file)
         if not hashedHues[frameName] then
            hashedHues[frameName] = MAD.image.score.hue(file)
         end
         io.write(col.Green(n),' Images \r') io.flush()
      end
   end
   torch.save(ofile, hashedHues)
end
function MAD.dir.images.saveGaussianShuffle(idir)
   local odir = path.join(desktop, path.basename(idir)..'.localShuffle')
   print(odir)
   dir.makepath(odir)
   local files = MAD.dir.images.files(idir)
   for i, file in ipairs(files) do
      if string.find(file, '.jpg') or
         string.find(file, '.jpeg') or
         string.find(file, '.png') then
         local name = path.basename(file)
         local ofile = path.join(odir, name)
         if not path.exists(ofile) then
            local img = pixels.load(file)
            local oimg = MAD.image.transform.shuffle.gaussian(img)
            pixels.save(ofile, oimg)
         end
      end
   end
end
function MAD.dir.images.moveScored()
   local out = {
      filename = {}
   }
   local idir = '/Users/laeh/Desktop/DataCore/Images_TwitterSample/engagementWeighted/10k.engagementWeighted.lxxlvd'
   local pornDir = '/Users/laeh/Desktop/DataCore/Images_TwitterSample/engagementWeightedPorn'
   local scores = require(path.join(idir, 'XX.tsv'))
   local filenames = scores.filename
   local nfiles = #filenames
   for i = 1, nfiles do
      local XX_score = scores.XX[i]
      XX_score = tonumber(XX_score)
      -- print(XX_score)
      if XX_score >30 then
         table.insert(out.filename, filenames[i])
         dir.movefile(path.join(idir, filenames[i]),path.join(pornDir, filenames[i]) )
      end
   end
   -- print(out)
end
function MAD.dir.images.toJpg(idir)
   local files = MAD.dir.images.files(idir)
   for i, file in ipairs(files) do
      xlua.progress(i, #files)
      if string.find(string.lower(file), 'png') then
         local img = pixels.load(file, {
            type = 'float',
            channels = 3,
         })         
         pixels.save(stringx.replace(file, '.png', '.jpg'), img)
      end
   end
end
function MAD.dir.images.MoveOnSize(idir, odir, width, heigth)
   local files = MAD.image.files(idir)
   for i,file in ipairs(files) do
      xlua.progress(i, #files)
      local ok,img = pcall(pixels.load, file, {
         type = 'float',
         channels = 3,
      })
      if ok then
         local img = pixels.load(file)
         local dims = #img
         local w, h = dims[3], dims[2]
         local name = path.basename(file)
         local to
         if w == width and h == height then
            dir.makepath(odir)
            to = path.join(odir, name)
            dir.movefile(file,to)
         end
      end
   end
end
function MAD.dir.images.d1sCounts(d0, ofile)
   local counts = {}
   local ofile = ofile or d0..'.txt'
   local labelsSortedStrings = {}
   local d1s = dir.getdirectories(d0)
   for _,d1 in ipairs(d1s) do
      local name = path.basename(d1)
      local files = dir.getallfiles(d1,extension)
      local nfiles = #files
      table.insert(counts, {
         count = nfiles,
         name = name,
      })
   end
   table.sort(counts, function(a,b) return a.count > b.count end)
   local total = 0
   for i, labelInfo in ipairs(counts) do
      total = total + 1
      local label  = stringx.ljust(tostring(labelInfo.name)..' ', 50)
      local count  = stringx.rjust(tostring(labelInfo.count)..' ', 16)
      local string = count..' | '..label..'\n'
      table.insert(labelsSortedStrings, string)
   end
   labelsSortedStrings = table.concat(labelsSortedStrings)

   local file = io.open(ofile,'w')
   file:write(labelsSortedStrings)
   file:close()
   os.execute('open "'..ofile..'"')
end
function MAD.dir.images.tocsv(idir, ofile)
   local csv = require('csv')
   local ofile = ofile or idir..'.csv'
   local out = {
      label = {},
      filename = {},
   }
   for i,d in ipairs(dir.getdirectories(idir)) do
      local label = paths.basename(d)
      for j,file in ipairs(MAD.dir.images.files(d)) do
         table.insert(out.label, label)
         table.insert(out.filename, path.basename(file))
      end
   end
   -- print(out)
   csv.save(ofile..'.csv', out)
   print('')
   print(col.Magenta('ids from '),  col.Yellow(idir)  )
   print(col.Magenta('saved @  '),  col.Yellow(ofile) )

   -- local result = require(ofile)
   -- print(result)

   -- local index = {}
   -- for i = 1,#result.filename do
   --    local filename = result.filename[i]
   --    local label = result.label[i]
   --    index[label] = index[label] or {}
   --    table.insert(index[label], filename)
   -- end
   -- print{index}
   -- local result = csv.load({path='result.csv', mode='query'})
   -- print('')
   -- print('query SC.soccer:')
   -- print(result('match', {label = 'SC.soccer'}))
end
MAD.dir.periscope = {}
function MAD.dir.periscope.bin(pdir, binSize)

   -- Args
   local pdir = pdir or error('!!pdir')
   local binSize = binSize or 5000

   -- Folders
   local idir = pdir..'-TEMP'
   local odir = pdir
   dir.movefile(pdir, idir)
   dir.makepath(odir)
   local files = dir.getallfiles(idir, '.ts')
   -- local files = images_files(idir)
   local s = binSize
   local totalFiles = #files
   local n = math.ceil(totalFiles/s)
   local counter = 0
   local c = 0
   print(col.Yellow(stringx.rjust('totalFiles', 30) ), col.Magenta( totalFiles) )
   print(col.Yellow(stringx.rjust('binSize', 30) ), col.Magenta( binSize) )
   print(col.Yellow(stringx.rjust('nBin', 30) ), col.Magenta( n) )
   for i=1, n do
      local vmin = (i-1) * s
      local vmax = (i-0) * s
      if i == n then
         s = totalFiles - vmin
         vmax = totalFiles
      end
      local sname = s
      if s == 2000 then sname = '2000' end
      if s == 1000 then sname = '1k' end
      if s == 5000 then sname = '5k' end
      if s == 50000 then sname = '50k' end
      if s == 10000 then sname = '10k' end
      local name = path.basename(pdir)
      -- local oname = sname..'.'..name..'.'..MAD.uid()
      local no = string.format('%03d',i)
      local oname = name..'.'..sname..'.'..no
      local obin = odir..'/'..oname dir.makepath(obin)
      for j=1, s do
         xlua.progress(j, s)
         counter = counter + 1
         local file = files[counter]
         local fname = path.basename(file)
         local to = obin..'/'..fname
         dir.movefile(file, to)
      end
   end
   dir.rmtree(idir)
end
function MAD.dir.periscope.flatten(idir, odir)
   odir = odir or idir..'.flat'
   dir.makepath(odir)
   local files = dir.getallfiles(idir,'.ts')
   for i, file in ipairs(files) do
      local fname = path.basename(file)
         local to = odir..'/'..fname
      local cmd1 = 'mv "'..file..'" "'..to..'"'
      print(cmd1) os.execute(cmd1)

   end
   -- Remove idir
   local cmd2 = 'rm "'..idir..'"'
   print(cmd2) os.execute(cmd2)
end
function MAD.dir.periscope.d1sCounts(d0, ofile)
   local counts = {}
   local ofile = ofile or d0..'.txt'
   local labelsSortedStrings = {}
   local d1s = dir.getdirectories(d0)
   for _,d1 in ipairs(d1s) do
      local name = path.basename(d1)
      local files = MAD.dir.medias.files(d1)
      local nfiles = #files
      print(name,nfiles)
      table.insert(counts, {
         count = nfiles,
         name = name,
      })
   end
   table.sort(counts, function(a,b) return a.count > b.count end)
   local total = 0
   for i, labelInfo in ipairs(counts) do
      total = total + 1
      local label  = stringx.ljust(tostring(labelInfo.name)..' ', 50)
      local count  = stringx.rjust(tostring(labelInfo.count)..' ', 16)
      local string = count..' | '..label..'\n'
      table.insert(labelsSortedStrings, string)
   end
   labelsSortedStrings = table.concat(labelsSortedStrings)

   local file = io.open(ofile,'w')
   file:write(labelsSortedStrings)
   file:close()
   os.execute('open "'..ofile..'"')
end
function MAD.dir.periscope.validate()
   local d0 = '/Volumes/Videos/CKO/training200k/training_200k/NO'
   local od0 = d0..'.invalid'
   dir.makepath(od0)
   local files = dir.getallfiles(d0,'.ts')
   local n = 0
   for i, file in ipairs(files) do
      local v = sys.execute('validate'..' < '..file) ~= 'success'
      if not v then
         n = n + 1
         local newfile = od0..'/'..path.basename(file)
         dir.movefile(file, newfile)
         print(n)
      end
   end
end
function MAD.dir.periscope.isDark(file, threshold)
   local function decodeKeyFrames(file, opt)
      local ok,ret = pcall(function()
         opt = opt or {}
         opt.inputSize = opt.inputSize or 64
         local res = torch.ByteStorage(file)
         local vireo = require 'libluavireo'
         local pixels = require 'pixels'
         local media
         if res then
            if type(res) == 'string' then
               media = vireo.Media(function() return torch.ByteStorage():string(res) end)
            elseif torch.typename(res) == 'torch.ByteStorage' then
               media = vireo.Media(function() return res end)
            elseif torch.typename(res) == 'torch.ByteTensor' then
               media = vireo.Media(function() return res:storage() end)
            else
               error('input type not recognized')
            end
            local desc = media:videoTrack()
            local buffers = {}
            local ts = {}
            for i = 1,desc:count() do
               local image = desc:image(i)
               local isKeyframe = image:keyframe()
               if isKeyframe then
                  table.insert(buffers, pixels.crop( image:size(nil,opt.inputSize):toTensor('byte','rgb') ))
                  table.insert(ts, i)
               end
            end
            return buffers
         end
      end)
      if ok then return ret end
   end

   if file then
      local frames = decodeKeyFrames(file)
      if frames then
         local average = 0
         for _,frame in ipairs(frames) do
            average = average + frame:float():mean()/#frames
            -- print(average)
         end
         return (average <= threshold)
      else
         print('skipping bad file at ' .. file)
      end
   end
end
function MAD.dir.periscope.isDarkMove(idir, threshold)
   local odir = idir..'.dark-'..threshold
   dir.makepath(odir)
   local files = dir.getallfiles(idir, '.ts')
   local n = 1
   for i, file in ipairs(files) do
      -- xlua.progress(i, #files)
      if file then
         local fname = path.basename(file)
         print(periscope.isDark(file, threshold))
         if periscope.isDark(file, threshold) then
            print(file)
            local to = odir..'/'..fname:gsub('.mp4','.ts')
            local cmd = 'mv "'..file..'" "'..to..'"'
            os.execute(cmd)
         end
      end
   end
end
function MAD.dir.periscope.mp4(idir)
   local mp4s = dir.getallfiles(idir, '.mp4')
   for i, file in ipairs(mp4s) do
      xlua.progress(i, #mp4s)
      local newfile = file:gsub('mp4', 'ts')
      dir.movefile(file, newfile)
   end
end
function MAD.dir.periscope.dirclean(idir)
   local L = 20000
   local B = 2000
   local d1s = dir.getdirectories(idir)
   for i, d1 in ipairs(d1s) do
      local files = dir.getallfiles(d1, '.ts')
      local total = #files
      if total > L then
         print(d1, 'more than '..L..' files; Skipping bining')
      else
         print(d1, total, math.ceil(total/B) )
         MAD.files.bin(d1, '.ts', 2000)
      end
   end
end
function MAD.dir.periscope.fileSizes(idir)
   local files = dir.getallfiles(idir, '.ts')
   local sizes = {}
   for i, file in ipairs(files) do
      table.insert(sizes, path.getsize(file))
   end
   local tcount = torch.Tensor(sizes)
   local counts_min = tcount:min()     print('min',counts_min)
   local counts_max = tcount:max()     print('max',counts_max)
   local counts_mean = tcount:mean()   print('mean',counts_mean)
   local counts_std = tcount:std()     print('std',counts_std)
   print(   col._blue( stringx.rjust('counts_min', 20 ) ),   torch.round(counts_min) )
   print(   col._blue( stringx.rjust('counts_max', 20 ) ),   torch.round(counts_max) )
   print(   col._blue( stringx.rjust('counts_mean', 20 ) ),  torch.round(counts_mean) )
   print(   col._blue( stringx.rjust('counts_std', 20 ) ),   torch.round(counts_std) )
end
MAD.dir.videos = {}
function MAD.dir.videos.decode(idir)
   local idir = idir or error('!!idir')
   local framesDirectory = idir..'.frames'
   local fps = 30
   local command = 'th scripts/decodeVideoDir.lua --idir '..idir..' --odir '..framesDirectory..' --fps '..fps
   os.execute(command)
end
MAD.mosaic = {
   options = {
      moments = {tw=64,th=96,mr=64/96},
      taxonomy = {tw=64,th=64,mr=1},
   }
}
function MAD.mosaic.mean(opt)
   opt = opt or {}
   local files       = opt.files or error('!! files' )
   local fmosaic     = opt.fmosaic or error('!! fmosaic' )
   local fmean       = opt.fmean or error('!! fmean' )
   local mosaicRatio = opt.mosaicRatio or error('!! mosaicRatio' )
   local tileWidth   = opt.tileWidth or error('!! tileWidth' )
   local tileHeight  = opt.tileHeight or error('!! tileWidth' )
   local imageRatio = tileWidth/tileHeight
   local nfiles = #files
   local nCol = math.floor(math.sqrt(nfiles * mosaicRatio / imageRatio))
   local nRow = math.floor(nfiles/nCol)
   local h = nRow * tileHeight
   local w = nCol * tileWidth
   local map = torch.FloatTensor(3, h, w):uniform( 0,.1)
   local muSize = 1024
   local sum = torch.FloatTensor(3,muSize,muSize)
   sum:zero()

   function p(string, value)
      print( stringx.rjust(string, 30), col.Blue(value))
   end

   -- p('name',path.basename(fmosaic))
   -- p('n',nfiles)
   -- p('Grid:',nCol..' * '..nRow)
   -- p('Tiles', tileWidth..' * '..tileHeight)
   -- p('Mosaic', w..' * '..h)
   -- p('fmosaic',fmosaic)
   -- p('fmean',fmean)

   local counter = 1
   for i = 1,nRow do
      for j = 1,nCol do
         xlua.progress(counter,#files)
         local file = files[counter]
         if file and pixels.guessFileType(file) then
            local ok,img = pcall(pixels.load, file, {
               minSize = math.min(tileWidth,tileHeight),
               type = 'float',
               channels = 3,
            })
            if ok then
               img = image.scale( MAD.image.crop(img, imageRatio), tileWidth, tileHeight)
               local t = (i-1) * tileHeight + 1
               local l = (j-1) * tileWidth + 1
               local b = t + tileHeight - 1
               local r = l + tileWidth - 1
               map[{ {},{t,b},{l,r} }] = img
               counter = counter + 1

               local imgbis = image.scale( pixels.crop(img), muSize, muSize)
               local imgbisfloat = imgbis:float()
               sum:add(imgbisfloat)
               -- img:set()
               imgbis:set()
               imgbisfloat:set()
            end

         end
      end
   end
   sum:div(sum:max())
   pixels.save(fmean, sum)
   sum:set()
   pixels.save(fmosaic, map)
   print('\n')
end
function MAD.mosaic.files(opt)
   opt = opt or {}
   local files       = opt.files or error('!! files' )
   local fmosaic     = opt.fmosaic or error('!! fmosaic' )
   local mosaicRatio = opt.mosaicRatio or error('!! mosaicRatio' )
   local tileWidth   = opt.tileWidth or error('!! tileWidth' )
   local tileHeight  = opt.tileHeight or error('!! tileWidth' )
   local imageRatio = tileWidth/tileHeight
   local nfiles = #files
   local nCol = math.floor(math.sqrt(nfiles * mosaicRatio / imageRatio))
   local nRow = math.floor(nfiles/nCol)
   local h = nRow * tileHeight
   local w = nCol * tileWidth
   local map = torch.FloatTensor(3, h, w):uniform( 0,.1)
   local muSize = 1024

   function p(string, value)
      print( stringx.rjust(string, 30), col.Blue(value))
   end

   p('name',path.basename(fmosaic))
   p('n',nfiles)
   p('Grid:',nCol..' * '..nRow)
   p('Tiles', tileWidth..' * '..tileHeight)
   p('Mosaic', w..' * '..h)
   p('fmosaic',fmosaic)

   local counter = 1
   for i = 1,nRow do
      for j = 1,nCol do
         xlua.progress(counter,#files)
         local file = files[counter]
         if file and pixels.guessFileType(file) then
            local ok,img = pcall(pixels.load, file, {
               minSize = math.min(tileWidth,tileHeight),
               type = 'float',
               channels = 3,
            })
            if ok then
               img = image.scale( MAD.image.crop(img, imageRatio), tileWidth, tileHeight)
               local t = (i-1) * tileHeight + 1
               local l = (j-1) * tileWidth + 1
               local b = t + tileHeight - 1
               local r = l + tileWidth - 1
               map[{ {},{t,b},{l,r} }] = img
               counter = counter + 1

               local imgbis = image.scale( pixels.crop(img), muSize, muSize)
               local imgbisfloat = imgbis:float()
               imgbis:set()
               imgbisfloat:set()
            end

         end
      end
   end
   pixels.save(fmosaic, map)
   print('\n')
end
function MAD.mosaic.meanApply(d0)
   local od0 = d0..'.MOMU'
   dir.makepath(od0)
   local d1s = dir.getdirectories(d0)
   -- print(d1s)
   for i, d1 in ipairs(d1s) do
      xlua.progress(i, #d1s)
      print(d1)
      local fmosaic = path.join(od0, path.basename(d1)..'.mo.jpg')
      local fmean = path.join(od0, path.basename(d1)..'.mu.jpg')
      if not path.exists(fmosaic) or not path.exists(fmean) then
         local files = MAD.dir.images.files(d1)
         if #files > 0 then 
            local ok = pcall(function()
                  MAD.mosaic.mean({
                     files = files,
                     fmosaic = fmosaic,
                     fmean = fmean,
                     tileWidth = 128,
                     tileHeight = 128,
                     mosaicRatio = 1,
                  })
            end)
         end
      end
   end
end
MAD.rdm = {}
function MAD.rdm.letter()
   local alphabet = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
   return MAD.sample(alphabet)
end
function MAD.rdm.glue()
   print('MAD.rdm.glue()')
   local strings = {}
   local idx = math.floor(torch.uniform(2,3))
   for i=1, idx do
      table.insert(strings, MAD.rdm.letter())
   end
   local word_string = table.concat(strings)
   print(word_string)
   return word_string
end
function MAD.rdm.word()
   print('MAD.rdm.word()')
   local strings = {}
   local idx = math.floor(torch.uniform(5,13))
   for i=1, idx do
      table.insert(strings, MAD.rdm.letter())
   end
   local word_string = table.concat(strings)
   print(word_string)
   return word_string
end
function MAD.rdm.symbol()
   print('MAD.rdm.symbol()')
   return MAD.sample({
      MAD.rdm.glue(),
      MAD.rdm.word(),
      MAD.rdm.word(),
      MAD.rdm.word()
   })
end
function MAD.rdm.title()
   local strings = {}
   for i = 1, 3 do
      table.insert(strings, MAD.rdm.symbol()..' ')
   end
   local title = table.concat(strings)
   print(title)
   return title
end


return MAD



