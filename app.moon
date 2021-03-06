_ = require 'lodash'
conf = require 'conf'
util = require 'util'
layout = require 'layout'
mouse = require 'mouse'
{
  keyStroke: press
  keyStrokes: send
} = hs.eventtap

toggle = false
app =
  toggle: (id, maximize) =>
    toggle = true
    a = hs.application.frontmostApplication!
    if a\bundleID! == id
      a\hide!
    else
      hs.application.launchOrFocusByBundleID id
      layout\maximize! if maximize

posTable = {}
lastName = nil
hs.application.watcher.new((name, event, app) ->
  eventName = nil
  switch event
    when hs.application.watcher.activated
      eventName = 'activated'
    when hs.application.watcher.terminated
      eventName = 'terminated'
    when hs.application.watcher.deactivated
      unless name
        return
      eventName = 'deactivated'
    when hs.application.watcher.hidden
      eventName = 'hidden'
      return
    when hs.application.watcher.unhidden
      eventName = 'unhidden'
      return
    when hs.application.watcher.launched
      eventName = 'launched'
      return
    when hs.application.watcher.launching
      eventName = 'launching'
      return
  -- if lastName == 'SecurityAgent' and util\checkSecurityAgent! == '1'
  --   send util\getSysPwd!
  --   if _.includes({'系统偏好设置'}, name)
  --     press {}, 'return'
  if eventName == 'activated'
    lastName = name
  else
    posTable[tostring(name)] = hs.mouse.getAbsolutePosition!
    pos = posTable[tostring(lastName)]
    win = layout\win!
    frame = win\frame!
    if toggle
      hs.mouse.setAbsolutePosition(if pos and (conf.app.allowOutside or hs.geometry(pos)\inside(frame)) then pos else frame.center)
      toggle = false
    lastName = nil
)\start!

-- hs.distributednotifications.new((name, object, userInfo) ->
--   if name == 'com.apple.SecurityAgent.consoleLogin.UIShown'
--     send util\getSysPwd!
-- )\start!
-- hs.timer.doEvery(1, ()->{
--   print hs.execute('/usr/local/bin/pidof SecurityAgent')
-- })

app
