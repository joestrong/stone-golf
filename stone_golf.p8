pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- main
state=0

function _update()
	if state==0 then
		update_aim()
	elseif state==1 then
		update_throw()
	elseif state==2 then
		update_run_to_rock()
	end
end

function _draw()
	cls(1)
 draw_tiles()
 
 if state==0 then
	 line(
	 	player.x,
	 	player.y,
	 	aim.x,
	 	aim.y
	 )
	 -- aim sprite
	 spr(
	 	0x10,
	 	aim.x-4,
	 	aim.y-4
	 )
 end
 -- player sprite
 spr(
 	3,
 	player.x-8,
 	player.y-15,
 	2,
 	2
 )

 if rock.visible==1 then
 	-- rock shadow
 	spr(
 		32,
 		rock.x-4,
 		rock.y-4
 	)
 	-- rock sprite
 	spr(
 		0,
 		rock.x-4,
 		rock.y-4+rock.z
 	)
 end
 
 if smash.visible==true then
 	-- smash sprite
 	spr(
 		17,
 		smash.x-4,
 		smash.y-4
 	)
 end
 
 -- bell shadow
 local bell_pos=tile_to_pix(bell.x,bell.y)
 spr(
 	32,
 	bell_pos.x-4,
 	bell_pos.y-6
 )
 -- bell sprite
 spr(
 	33,
 	bell_pos.x-4,
 	bell_pos.y-bell.z
 )
end
-->8
-- tiles

x_o=0
x_len=5
y_o=3
y_len=5

function draw_tiles()
	for y=0,x_len-1,1 do
		for x=0,y_len-1,1 do
			local pos=tile_to_pix(x,y)
			map(0,0,pos.x,pos.y-8,4,2)
		end
	end
end

function pix_to_tile(x,y)
	tilex=flr(((x-x_o*32)/32)-((y-y_o*16)/16))
	tiley=flr(((y-y_o*16)/16)+((x-x_o*32)/32))
	return {
		x=tilex,
		y=tiley
	}
end

function tile_to_pix(x,y)
	local posx=x*16+y*16+x_o*32
	local posy=y*8-x*8+y_o*16
	return {
		x=posx,
		y=posy
	}
end
-->8
-- player
angle=0
power=10
gravity=.25

player={
	x=64,
	y=64
}
rock={
	x=0,
	y=0,
	z=0,
 angle=0,
	vel_h=0,
	vel_v=0,
	visible=0
}
aim={
	x=0,
	y=0,
	length=40
}
smash={
	x=0,
	y=0,
	visible=false
}
bell={
	x=4,
	y=3,
	z=32
}

function update_aim()
	if btn(⬅️) then
		angle+=0.01	
	end
	if btn(➡️) then
		angle-=0.01	
	end
	if btn(❎) then
		rock.visible=1
		rock.vel_h=power/2
		rock.vel_v=-power/5
		rock.angle=angle
		rock.z=0
		rock.x=player.x
		rock.y=player.y
		state=1
  sfx(0)
	end
	aim.x=cos(angle)*aim.length+player.x
	aim.y=sin(angle)*(aim.length/2)+player.y
end

function update_throw()
	rock.z+=rock.vel_v
	rock.x=cos(rock.angle)*rock.vel_h+rock.x
	rock.y=sin(rock.angle)*(rock.vel_h/2)+rock.y
	rock.vel_v+=gravity
	tile=pix_to_tile(rock.x,rock.y)
	if smash.visible==false
	and (
		tile.x < 0
		or tile.y < 0
		or tile.x > x_len-1
		or tile.y > y_len-1
	) then
		smash.x=rock.x
		smash.y=rock.y+rock.z
		smash.visible=true
		sfx(1)
	end
	if rock.z==0 then
		rock.x=flr(rock.x)
		rock.y=flr(rock.y)
		state=2
		sfx(2)
	end
end

function update_run_to_rock()
	if player.x==rock.x
	and player.y==rock.y then
		aim.x=player.x
		aim.y=player.y
		rock.visible=0
		state=0
	end
	
	if player.x>rock.x then
		player.x-=1
	end
	if player.x<rock.x then
		player.x+=1
	end
	if player.y>rock.y then
		player.y-=1
	end
	if player.y<rock.y then
		player.y+=1
	end
--		local run_angle=atan2((rock.y-player.y)/(player.x-rock.x))
--		player.x+=cos(run_angle)*.5
--		player.y+=sin(run_angle)*.5	
end
__gfx__
00000000000000330000000000000444444000000000000000000033330000000000000000000000000000000000000000000000000000000000000000000000
000666d0000033333300000000004444444400000000000000003333333300000000000000000000000000000000000000000000000000000000000000000000
00666ddd0033333333330000000444ff444440000000000000bbb333333bbb000000000000000000000000000000000000000000000000000000000000000000
0666dddd33333333333333000004fff44fff400000000000bbbbbbb33bbbbbbb0000000000000000000000000000000000000000000000000000000000000000
6666dddd3333333333333300000fff1ff1fff000000000bbbbbbbb3333bbbbbbbb00000000000000000000000000000000000000000000000000000000000000
666666dd00333333333300000000ffffffff00000000bbbbbbbb33333333bbbbbbbb000000000000000000000000000000000000000000000000000000000000
006666dd00003333330000000000fff22fff0000003333bbbb333333333333bbbb33330000000000000000000000000000000000000000000000000000000000
000000000000003300000000000000ffff0000003333333333333333333333333333333300000000000000000000000000000000000000000000000000000000
00000000070070000000000000000888888000000333333bb33333333333333bb333333000000000000000000000000000000000000000000000000000000000
070770700777070000000000000088888888000000033bbbbbb3333333333bbbbbb3300000000000000000000000000000000000000000000000000000000000
007007000700077700000000000888888888800000000bbbbbbbb333333bbbbbbbb0000000000000000000000000000000000000000000000000000000000000
07077070070000700000000000ff0111111dff000000000bbbbbbbb33bbbbbbbb000000000000000000000000000000000000000000000000000000000000000
07077070700007700000000000f00110011ddf00000000000bbbbb3333bbbbb00000000000000000000000000000000000000000000000000000000000000000
007007000770700000000000000001100110000000000000000b33333333b0000000000000000000000000000000000000000000000000000000000000000000
0707707000070700000000000000ccc00ccc00000000000000000333333000000000000000000000000000000000000000000000000000000000000000000000
0000000000000700000000000000ccc00ccc00000000000000000003300000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009999aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111110000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0506070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516171800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000b0500f0501405016050190501c0501e0501f0501f0501e0500b050070500e050140501505014050120500f0500a05008050050500505007050080500805008050060500505002050000000000000000
00010000000003c6503d6503d6503d6503b65039650346502e6502865023650216501e6501d6501d6501c6501a6501965015650126500e6500b65008650066500565004650046500465005650056500565004650
0001000003450074500a4500c4500e4501045011450114501245011450104500d4500945005450014500045004450004500555000550005500050000500005000050000500005000050000500005000000000000
