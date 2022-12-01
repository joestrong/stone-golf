pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- main
-- 0 = aim
-- 1 = throw
-- 2 = run
-- 3 = main menu
-- 4 = init level
state=3
tick=0

function _update()
	tick+=1
	if state==0 then
		update_aim()
	elseif state==1 then
		update_throw()
		if bell.hit==true then
			update_ring_bell()
		end
	elseif state==2 then
		update_run_to_rock()
	elseif state==3 then
		update_menu()
	elseif state==4 then
		update_init_level()
	end
end

function _draw()
	if state==3 then
		draw_menu()
	else
		draw_game()
	end
end

function draw_game()
	cls(1)
 draw_tiles()
 
 if state==0 then
	 -- curve line
	 local vangle=vangle
	 local prevx=0
	 local prevy=0
	 local segment
	 for i=1,5,1 do
	 	segment=aim.length/5*i
	 	local height=tan(vangle)*segment
	 	if height<=0 then
	 		break
	 	end
	 	local nextx=(aim.x-player.x)/5*i
	 	local nexty=(aim.y-player.y)/5*i-height
	 	line(
	 		player.x+(prevx),
	 		player.y+(prevy),
	 		player.x+(nextx),
	 		player.y+(nexty),
	 		7
	 	)
	 	vangle+=0.02
	 	prevx=nextx
	 	prevy=nexty
	 end
	 -- bottom line
	 line(
	 	player.x,
	 	player.y,
	 	aim.x,
	 	aim.y,
			5
	 )
	 -- aim sprite
	 spr(
	 	0x10,
	 	player.x+prevx-4,
	 	player.y+prevy-4
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
 spr(
 	32,
 	bell.x-4,
 	bell.y-6
 )
 -- bell sprite
 spr(
 	bell.sprite,
 	bell.x-4,
 	bell.y+bell.z
 )
end

function tan(a) return sin(a)/cos(a) end
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
vangle=-0.1
power=5
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
local bell_pos=tile_to_pix(4,3)
bell={
	x=bell_pos.x,
	y=bell_pos.y,
	z=-32,
	sprite=34,
	hit=false,
	hitlen=0
}

function update_init_level()
	player.x=64
	player.y=64
	angle=0
	vangle=-0.1
	rock.visible=0
	bell.sprite=34
	bell.hit=false
	smash.visible=false
	state=0
end

function update_aim()
	if btn(⬅️) then
		angle+=0.01	
	end
	if btn(➡️) then
		angle-=0.01	
	end
	if btn(⬇️) then
		vangle-=0.01
		if vangle<-0.2 then
			vangle=-0.2
		end
	end
	if btn(⬆️) then
		vangle+=0.01
		if vangle>-0.05 then
			vangle=-0.05
		end
	end
	if btn(❎) then
		rock.vel_h=cos(vangle)*power
		rock.vel_v=-sin(vangle)*power
		rock.visible=1	
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
	if rock.z>=0 then
		rock.x=flr(rock.x)
		rock.y=flr(rock.y)
		rock.z=0
		if bell.hit==false
			and smash.visible==false then
			state=2
			sfx(2)
		end
	end
	if collide(rock,bell)
		and bell.hit==false then
		bell.hit=true
		bell.hitlen=20
		sfx(3)
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

function update_ring_bell()
	if bell.hitlen<=0 then
		state=3
		sfx(-2)
		bell.hitlen=0
	end
	if tick%3==0 then
		bell.sprite+=1
	end
	if bell.sprite>36 then
		bell.sprite=33
	end
	bell.hitlen-=1
end

function collide(obj1,obj2)
	local range=5
	if obj1.x > obj2.x+range
		or obj1.x < obj2.x-range then
		return false
	end
	if obj1.y > obj2.y+range
		or obj1.y < obj2.y-range then
		return false
	end
	if obj1.z > obj2.z+range
		or obj1.z < obj2.z-range then
		return false
	end
	
	return true
end
-->8
-- menu

function update_menu()
 if btn(🅾️) then
 	state=4
 end
end

function draw_menu()
	cls(1)
	spr(
		9,
		50,
		50,
		3,
		3
	)
	print("level 1",50,80)
 print("press 🅾️",50,90)
end
__gfx__
00000000000000330000000000000444444000000000000000000033330000000000000000000000000000000000000000000000000000000000000000000000
000666d000003333330000000000444444440000000000000000333333330000000000000000000000000dd00000000000000000000000000000000000000000
00666ddd0033333333330000000444ff444440000000000000bbb333333bbb000000000000000000000dd00d0000000000000000000000000000000000000000
0666dddd33333333333333000004fff44fff400000000000bbbbbbb33bbbbbbb00000000000000000dd00000d000000000000000000000000000000000000000
6666dddd3333333333333300000fff1ff1fff000000000bbbbbbbb3333bbbbbbbb0000000000000dd00000000d00000000000000000000000000000000000000
666666dd00333333333300000000ffffffff00000000bbbbbbbb33333333bbbbbbbb0000000000d00d0000d000d0000000000000000000000000000000000000
006666dd00003333330000000000fff22fff0000003333bbbb333333333333bbbb33330000000d0000d00d00000d000000000000000000000000000000000000
000000000000003300000000000000ffff000000333333333333333333333333333333330000d000000d0000000dd00000000000000000000000000000000000
00000000070070000000000000000888888000000333333bb33333333333333bb3333330000d000d0000d0000dd0d00000000000000000000000000000000000
070770700777070000000000000088888888000000033bbbbbb3333333333bbbbbb3300000d000d000000d0dd000d00000000000000000000000000000000000
007007000700077700000000000888888888800000000bbbbbbbb333333bbbbbbbb000000d000d00000d00d00000d00000000000000000000000000000000000
07077070070000700000000000ff0111111dff000000000bbbbbbbb33bbbbbbbb00000000d00000000d000d00000d00000000000000000000000000000000000
07077070700007700000000000f00110011ddf00000000000bbbbb3333bbbbb0000000000d00d000000000d000d0d00000000000000000000000000000000000
007007000770700000000000000001100110000000000000000b33333333b000000000000dd000dddd0000d00d00d00000000000000000000000000000000000
0707707000070700000000000000ccc00ccc0000000000000000033333300000000000000d0000d00d0000d0d000d00000000000000000000000000000000000
0000000000000700000000000000ccc00ccc0000000000000000000330000000000000000d00d0d00d00d0d0000dd00000000000000000000000000000000000
00000000000aa000000aa000000aa000000aa000000000000000000000000000000000000d0d00d0dd0d00d00dd0000000000000000000000000000000000000
000000000aaaaa0000aaaa0000aaaaa000aaaa00000000000000000000000000000000000d0000d00d0000ddd000000000000000000000000000000000000000
000000009aaaaa0000aaaa0000aaaaaa00aaaa00000000000000000000000000000000000dddddddddddddd00000000000000000000000000000000000000000
0000000099aaaa00099aaaa0009aaaaa099aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999aaa0009999aa000999aaa09999aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011111110099a0000099990000099900009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111110080000000008000000000080000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0506070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516171800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000b0500f0501405016050190501c0501e0501f0501f0501e0500b050070500e050140501505014050120500f0500a05008050050500505007050080500805008050060500505002050000000000000000
00010000000003c6503d6503d6503d6503b65039650346502e6502865023650216501e6501d6501d6501c6501a6501965015650126500e6500b65008650066500565004650046500465005650056500565004650
0001000003450074500a4500c4500e4501045011450114501245011450104500d4500945005450014500045004450004500555000550005500050000500005000050000500005000050000500005000000000000
00010614151501615018150191501a1501c1501c1501e1501e1501f15000150001501f1501f1500d150001501f1501e1501d1501c1501b1501a1501815016150141501315012150111500e1500a1500010000100
