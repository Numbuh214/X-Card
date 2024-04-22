--- STEAMODDED HEADER
--- MOD_NAME: X Card
--- MOD_ID: X_Card
--- MOD_AUTHOR: [Numbuh214]
--- MOD_DESCRIPTION: Adds the enhancement "X Card" to the game. X Cards have wild ranks, but two X Cards in the same hand cannot mimic the same rank.
--- PRIORITY: 1000
----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.X_Card()
    local this_mod = SMODS.findModByID("X_Card")
    local x_card = {
      name = "X Card",
      slug = "m_xcard",
      sprite = "m_xcard",
      pos = {x=0,y=2},
      effect = "X Card",
      label = "X Card",
      playing_card = true,
      display_face = false,
      config = {
        extra = {
        },
      },
      loc_txt =
      {
        "When played, becomes the",
        "best {C:attention}unique{} rank possible"
      }
    }
    newEnhancement(x_card)
    --G.P_CENTERS.m_xcard = x_card
    --G.P_CENTER_POOLS['Enhanced'][x_card.order-1] = x_card
    --sendDebugMessage(tostring(G.P_CENTER_POOLS['Enhanced'][x_card.order-1].name))
    --G.localization.descriptions['Enhanced']['m_xcard']=

    local m_xcard_sprite = SMODS.Sprite:new(
      "m_xcard",
      this_mod.path,
      "m_xcard.png",
      71, 95,
      "asset_atli"
    )
    m_xcard_sprite:register()
    local pagecupssprite = SMODS.Sprite:new(
      "c_pagecups",
      this_mod.path,
      "c_pagecups.png",
      69, 93,
      "asset_atli"
    )
    pagecupssprite:register()
    local c_pagecups = SMODS.Tarot:new("Page of Cups", "pagecups", {mod_conv = 'm_xcard', max_highlighted = 1}, {x = 0, y = 0}, {
      name = "Page of Cups",
      text = {
        "Enhances {C:attention}#1#{} selected",
        "card into an",
        "{C:attention}#2#"
      }
    }, 2, 1.0, "Enhance", true, true, "c_pagecups")
    c_pagecups:register()
    c_pagecups.set_badges = function(self, badges)
        badges = badges or {}
        badges[1] = create_badge("Tarot", G.C.PURPLE, nil, 1.2)
        badges[2] = create_badge("Minor Arcana", G.C.PURPLE, nil, 0.9)
        return badges
    end
    c_pagecups.loc_def = function()
      return {
        c_pagecups.config.max_highlighted,
        "X Card"
      }
    end
    rank_names = {"Jack","Queen","King", "Ace"}
    for i=10, 2, -1 do
      table.insert(rank_names, 1, tostring(i))
    end
end

local nominalref = Card.get_nominal
function Card:get_nominal(mod)
    if self.ability.effect == 'X Card' then
      return (mod == suit and self.base.suit_nominal * 1000 or self.base.suit_nominal*100-5000)
    end
    return nominalref(self, mod)
end

local setability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
  if center.key == "m_xcard" then
      self.ability = {
        extra = {
          display_rank = false,
          display_face = false
        }
      }
  end
  return setability_ref(self, center, initial, delay_sprites)
end

local setsprites_ref = Card.set_sprites
function Card:set_sprites(_center, _front)
    if _center and _center.key and _center.key == "m_xcard" then
      if not self.ability then self.ability = {} end
      if not self.ability.extra then self.ability.extra = {} end
      if (self.ability.extra.display_rank == nil) then self.ability.extra.display_rank = false end
	  local suit = 0
	  if self.base and self.base.suit_nominal then
	    suit = self.base.suit_nominal * 100 - 1
	  end
	  if suit % 2 == 0 then
	    suit = 2 - suit
	  end
      if (self.ability.extra.display_rank == true) then
        self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS['cards_'..(G.SETTINGS.colourblind_option and 2 or 1)], {x = self.ability.extra.fake_rank-2, y = suit})
      else
        self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS['m_xcard'], {x = 0, y = suit})
      end
      self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS['centers'], {x = 1, y = 0})
      self.children.center:set_sprite_pos({x = 1, y = 0})
      if not self.children.back then
        self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["centers"], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))
        align_layer(self, self.children.back)
      end
      align_layer(self, self.children.front)
      align_layer(self, self.children.center)
    else
      setsprites_ref(self,_center,_front)
    end
end

function get_loc_vars(name)
    if name == 'Page of Cups' then
      --sendDebugMessage("Page of Cups found!")
      return {
        1,
        "X Card"
      }
    end
    if name == 'X Card' then
      --sendDebugMessage("X card found!")
      return {
        "Hearts"
      }
    end
    return nil
end

local clickref = Card.click
function Card:click()
  clickref(self)
  if self.highlighted ~= true then
    if self.ability and self.ability.extra and self.ability.extra.fake_rank ~= nil then
	  self.ability.extra.fake_rank = nil
	end
  end
end

local get_chip_bonus_ref = Card.get_chip_bonus
function Card:get_chip_bonus()
  if self.ability.effect == 'X Card' then
    if not self.ability.extra then self.ability.extra = {} end
    if self.ability.extra.fake_rank == nil then
      return 0
    end
    local postage = self.ability.extra.fake_rank
    if postage > 10 then
      local words = {"Jack","Queen","King","Ace"}
      --sendDebugMessage("Fake rank is ".. words[postage-10])
      postage = (postage == 14 and 11) or 10
    else
      --sendDebugMessage("Fake rank is ".. postage)
    end
    return postage + (self.ability.perma_bonus or 0)
  end
  return get_chip_bonus_ref(self)
end



local highlight_card_ref = highlight_card
function highlight_card(card, percent, dir)
    highlight_card_ref(card, percent, dir)
    if card ~= nil and card.ability ~= nil and card.ability.effect == 'X Card' then
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() card:flip();play_sound('tarot2', 0.95, 0.6);card:juice_up(0.3, 0.3);return true end }))
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.65,func = function() card:flip();play_sound('tarot1', 0.95, 0.6);card:juice_up(0.3, 0.3);card.ability.extra.display_rank = (dir == 'up');if dir ~= 'up' then card.ability.extra.random_rank = nil; end;card:set_sprites(card.config.center, card.config.front);return true end }))
    end
    -- if card.ability.extra and card.ability.extra.fake_rank then
      -- if dir == 'up' then
        -- card:set_base(card.ability.extra.fake_rank)
      -- else
        -- card:set_base(nil)
      -- end
    -- end
end

local evaluate_poker_hand_ref = evaluate_poker_hand
function evaluate_poker_hand(hand)
  local x_cards = {}
  for i=1, #hand do --reset all x card fake ranks
    if hand[i].config.center == G.P_CENTERS['m_xcard'] then
	  --sendDebugMessage(tostring(hand[i].ability.extra.fake_rank))
      table.insert(x_cards, hand[i])
    end
  end

  local results = {
    ["Flush Five"] = {},
    ["Flush House"] = {},
    ["Five of a Kind"] = {},
    ["Straight Flush"] = {},
    ["Four of a Kind"] = {},
    ["Full House"] = {},
    ["Flush"] = {},
    ["Straight"] = {},
    ["Three of a Kind"] = {},
    ["Two Pair"] = {},
    ["Pair"] = {},
    ["High Card"] = {},
    top = nil
  }

  local order = {
    "Flush Five",
    "Flush House",
    "Five of a Kind",
    "Straight Flush",
    "Four of a Kind",
    "Full House",
    "Flush",
    "Straight",
    "Three of a Kind",
    "Two Pair",
    "Pair",
    "High Card",
  }

  local of_a_kind = {
    "Three of a Kind",
    "Four of a Kind",
    "Five of a Kind"
  }

  results = evaluate_poker_hand_ref(hand)

  if #hand >=4 and #results["Straight"] == 0 then
    results["Two Pair"] = get_two_pair(results)
  end
  --results["Full House"] = get_full_house(results)
  if (next(get_flush(hand))) then
    results["Flush House"] = get_full_house(results)
  end
  for i=1, #hand do
    if hand[i].config.center == G.P_CENTERS['m_xcard'] then
	  --sendDebugMessage(tostring(hand[i].ability.extra.fake_rank))
	end
  end
  for i=1, #order do
    if #results[order[i]] > 0 then
      --sendDebugMessage("Hand is "..order[i].."...?")
      results["top"] = results[order[i]]
      break
    end
    --sendDebugMessage("Hand is not "..order[i]..".")
  end

  if results["top"] == results["Straight"] or results["top"] == results["Straight Flush"] then
    for i=1, #hand do
	  if hand[i].config.center == G.P_CENTERS['m_xcard'] then
	    hand[i].ability.extra.fake_rank = hand[i].ability.extra.straight_rank
	  end
	end
  end

  local x_cards = {}
  for i=1,#hand do
    if hand[i].config.center == G.P_CENTERS['m_xcard'] then
      if hand[i].ability.extra.fake_rank == nil then
        --sendDebugMessage("X Card #"..i.." has no fake rank...?")
		hand[i].ability.extra.fake_rank = hand[i].ability.extra.random_rank or nil
        while hand[i].ability.extra.fake_rank == nil do
          local rng = math.floor(pseudorandom('m_xcard')*13)+2
          for k, v in pairs(hand) do
            if v:get_id() == rng then
              --sendDebugMessage("Found "..rng.." in hand.")
            elseif v:get_id() >= 2 then
              --sendDebugMessage("Did not find "..rng.." in hand.")
              if not hand[i].ability.extra then hand[i].ability.extra = {} end
              hand[i].ability.extra.fake_rank = rng
			  hand[i].ability.extra.random_rank = rng
			  break
            end
          end
        end
      end
      table.insert(x_cards, hand[i])
    end
  end
  return results
end

function get_two_pair(results)
  if #results["Pair"] == 0 then return {} end
  local values = results["Pair"][1]
  if #values == 2 then
    --sendDebugMessage("Two pair found!")
    return {
      values[1][1],
      values[1][2],
      values[2][1],
      values[2][2],
    }
  end
  --sendDebugMessage("Two pair not found.")
  --print_table(values)
  return {}
end

function get_full_house(results)
  local tri = results["Three of a Kind"]
  if (#tri == 0) then return {} end
  local pair = results["Pair"]
  if (#pair == 0) then return {} end

  local results = {}
  for k, v in pairs(tri) do
    for k2, v2 in pairs(pair) do
	  if k2 ~= k then

	  end
    end
  end
  sendDebugMessage("Full House not found.")
  --print_table(values)
  return {}
end

local get_X_same_ref = get_X_same
function get_X_same(num, hand)
    if num > #hand then return {} end
    local ranks = {}
    local results = {}
	local x_index = {}
    local hand_type = (num == 2 and "pair(s)" or num.." of a kind(s)")
    --sendDebugMessage("Searching for "..hand_type.."...")
    for i=13, 1, -1 do
      if ranks[i] == nil then
        ranks[i] = {}
      end
      for j=1, #hand do
        if hand[j].config.center == G.P_CENTERS.m_xcard then
		  table.insert(x_index,j)
		elseif hand[j]:get_id() == i+1 then
          --sendDebugMessage("Adding real "..rank_names[i])
          table.insert(ranks[i],hand[j])
        end
      end
    end
	if #x_index >= 3 and num > 2 then return {} end
    for i = 13, 1, -1 do
      if #ranks[i] == num - 1 and #x_index > 0 then
	    hand[x_index[1]].ability.extra.fake_rank = i+1
        --sendDebugMessage("Adding fake "..rank_names[i])
		table.insert(ranks[i],hand[x_index[1]])
		table.remove(x_index,1)
	  end
      if #ranks[i] == num then
        --sendDebugMessage("There are "..#ranks[i].." cards of the "..rank_names[i].." rank in hand.")
        results[#results+1] =  ranks[i]
      end
    end
    if #results == 0 then
      --sendDebugMessage("No "..hand_type.." found...")
	  return {}
    else
      --sendDebugMessage(#results.." "..hand_type.." found...")
      return {results}
    end
end

local get_straight_ref = get_straight
function get_straight(hand)
    local can_loop = next(find_joker('Superposition')) and SMods.findModByID("NumBalatro") ~= nil
    local ret_hand = {}
    local ref_hand = {}
    local four_fingers = next(find_joker('Four Fingers'))
    local can_skip = next(find_joker('Shortcut'))

    if #hand > 5 or #hand < (5 - (four_fingers and 1 or 0)) then
      return get_straight_ref(hand)
    else
	  for i=1,#hand do
	    hand[i].temp_order = i
	  end
	  table.sort(hand, function (a, b) return a:get_id() > b:get_id() end)
      local delta_var = (can_skip and 2 or 1)
      local x_cards = {}
      local normal_ranks = {}
      local x_count = 0
      local check_var = hand[1]:get_id()
      local ace_in = check_var == 14
      local target = (four_fingers and 4 or 5)
      for i=1, #hand do
	    if not hand[i].ability then hand[i].ability = {} end
	    if not hand[i].ability.extra then hand[i].ability.extra = {} end
        if hand[i].config.center == G.P_CENTERS.m_xcard then
          table.insert(x_cards, i)
        else
          table.insert(normal_ranks, i)
        end
      end
	  if #x_cards == 0 then return get_straight_ref(hand) end
	  local results = {}
	  sendDebugMessage("There are "..#normal_ranks.." normal cards...?")
	  if #normal_ranks < 2 then
	    local id = 10
	    if #normal_ranks == 1 then
	      id = math.min(hand[normal_ranks[1]]:get_id(),10)
		end
		local fake = id
		local vals = {}
		table.sort(hand, function (a, b) return a.temp_order < b.temp_order end)
		for i=1,#hand-#normal_ranks do
		  if fake+i < 14 and can_skip then
		    fake = fake + 1
		  end
		  if fake+i == id then
		    sendDebugMessage("Skipped "..rank_names[fake+i-1])
		  else
		    sendDebugMessage("Added "..rank_names[fake+i-1])
		    vals[#vals+1] = fake+i
		  end
		end
		for i=1,#hand do
		  sendDebugMessage("Card "..i.." ("..#vals.." fake vals left)")
		  if hand[i].config.center == G.P_CENTERS.m_xcard and #vals > 0 then
			sendDebugMessage("Setting fake rank to "..rank_names[vals[1]-1])
			if not hand[i].ability then hand[i].ability = {} end
		    if not hand[i].ability.extra then hand[i].ability.extra = {} end
			hand[i].ability.extra.straight_rank = vals[1]
			table.remove(vals,1)
		  end
		  table.insert(results,1, hand[i])
		end
		if #results < target then return {} end
		return {results}
	  elseif #normal_ranks == 2 then
	    ids = {
		  hand[normal_ranks[1]]:get_id(),
		  hand[normal_ranks[2]]:get_id()
		}
	    sendDebugMessage(rank_names[ids[1]-1].." and "..rank_names[ids[2]-1].." are "..ids[1]-ids[2].." rank(s) apart.")
		if ids[1] - ids[2] > (target-1) * delta_var then return {} end
		fake = math.min(ids[2],ids[1]-1,9)
		vals = {}
		local o = 0
		for i=1, #hand do
		  if fake+i < ids[1] and can_skip then
		    fake = fake + 1
		  end
		  if fake+i == ids[1] or fake+i == ids[2] then
		    sendDebugMessage("Skipped "..rank_names[fake+i-1])
		  else
		    sendDebugMessage("Added "..rank_names[fake+i-1])
		    vals[#vals+1] = fake+i
		  end
		end
		table.sort(hand, function (a, b) return a.temp_order < b.temp_order end)
		for i=#hand,1,-1 do
		  sendDebugMessage("Card "..i.." ("..#vals.." fake vals left)")
		  if hand[i].config.center == G.P_CENTERS.m_xcard and #vals > 0 then
			sendDebugMessage("Setting fake rank to "..rank_names[vals[1]-1])
			if not hand[i].ability then hand[i].ability = {} end
		    if not hand[i].ability.extra then hand[i].ability.extra = {} end
			hand[i].ability.extra.straight_rank = vals[1]
			table.remove(vals,1)
		  end
		  table.insert(results,1, hand[i])
		end
		sendDebugMessage("Results: "..#results)
		if #results < target then return {} end
		return {results}
	  else
	    local prev_val = nil
		local first_val = hand[normal_ranks[1]]
		local offset = 1
		local vals = {}
		local fake_vals = {}
	    for i=2, #normal_ranks do
		  local ids = {
		    hand[normal_ranks[i-1]]:get_id(),
		    hand[normal_ranks[i]]:get_id()
		  }
		  if ids[1]-ids[2] <= delta_var+#x_cards then
		    if ids[1]-ids[2] > delta_var then
			  offset = i
			end
		    if i == 2 then
			  table.insert(vals,ids[1])
			  hand[normal_ranks[1]].ability.extra.add = true
			end
			table.insert(vals,ids[2])
			hand[normal_ranks[i]].ability.extra.add = true
		  end
		end
		print_table(vals)
		if #vals < target - #x_cards then return {} end
		local i = vals[offset]+1
		while #fake_vals < #x_cards do
		  if #vals == target - 1 and vals[target - 1] == 2 then
		    table.insert(fake_vals,14)
		  else
		    if i > 14 then i = 10 end
		    table.insert(fake_vals, i)
		    i = i + 1
		  end
		end
		for i = #x_cards, 1, -1 do
		  if #fake_vals == 0 then break end
		  hand[x_cards[i]].ability.extra.straight_rank = fake_vals[1]
		  hand[x_cards[i]].ability.extra.add = true
		  table.remove(fake_vals,1)
		end
		table.sort(hand, function (a, b) return a.temp_order < b.temp_order end)
		for i = 1, #hand do
		  if hand[i].ability.extra.add == true then
		    hand[i].ability.extra.add = nil
		    table.insert(results, hand[i])
		  end
		end
		if #results < target then return {} end
		return {results}
	  end
    end
	return {}
end

function invert(colour)
  return {
    1-colour[1],
    1-colour[2],
    1-colour[3],
    colour[4]
  }
end
----------------------------------------------
------------MOD CODE END----------------------
