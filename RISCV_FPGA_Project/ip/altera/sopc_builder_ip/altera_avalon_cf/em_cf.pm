#Copyright (C)2001-2010 Altera Corporation
#Any megafunction design, and related net list (encrypted or decrypted),
#support information, device programming or simulation file, and any other
#associated documentation or information provided by Altera or a partner
#under Altera's Megafunction Partnership Program may be used only to
#program PLD devices (but not masked PLD devices) from Altera.  Any other
#use of such megafunction design, net list, support information, device
#programming or simulation file, or any other related documentation or
#information is prohibited for any other purpose, including, but not
#limited to modification, reverse engineering, de-compiling, or use with
#any other silicon devices, unless such use is explicitly licensed under
#a separate agreement with Altera or a megafunction partner.  Title to
#the intellectual property, including patents, copyrights, trademarks,
#trade secrets, or maskworks, embodied in any such megafunction design,
#net list, support information, device programming or simulation file, or
#any other related documentation or information provided by Altera or a
#megafunction partner, remains with Altera, the megafunction partner, or
#their respective licensors.  No other licenses, including any licenses
#needed under any third party's intellectual property, are provided herein.
#Copying or modifying any file, or portion thereof, to which this notice
#is attached violates this copyright.






















package em_cf;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &make_em_cf
);

use europa_all;
use europa_utils;
use strict;









sub make_em_cf
{
  my ($project) = (@_);
  



  e_assign->adds(
    ["atasel_n",        "1'b0"],
    ["we_n",            "1'b1"],
    ["rfu",             "1'b1"],
    ["addr[10:3]",      "8'h00"],
    ["addr[2:0]",       "av_ide_address[2:0]"],
    ["iord_n",          "av_ide_read_n"],
    ["iowr_n",          "av_ide_write_n"], 
  );





  e_assign->adds(
    ["cs_n[0]",
      "~av_ide_chipselect_n ? (~av_ide_address[3] ? 1'b0 : 1'b1) : 1'b1"],

    ["cs_n[1]", 
      "~av_ide_chipselect_n ? ( av_ide_address[3] ? 1'b0 : 1'b1) : 1'b1"],
  );







  e_assign->adds(
    ["av_ide_readdata", "present_reg ? data_cf : 16'hFFFF"],
    ["data_cf", "(~av_ide_write_n && present_reg) ? av_ide_writedata :16'hZZZZ"],
  );
  





  e_assign->adds(
    ["power", "(power_reg && present_reg) ? 1'b1 : 1'b0"],
  );
  












  e_assign->adds(
    ["reset_n_cf", "(reset_reg || ~av_reset_n || ~present_reg) ? 1'b0 : 1'b1"],
  );






  e_assign->adds(
    ["av_ide_irq", "(ide_irq_en_reg && present_reg) ? intrq : 1'b0"],
  );
































  e_assign->adds(
    ["ctl_lo_write_strobe", "~av_ctl_chipselect_n && ~av_ctl_write_n && 
      (av_ctl_address == 4'h0)"],
      
    ["ctl_hi_write_strobe", "~av_ctl_chipselect_n && ~av_ctl_write_n &&
      (av_ctl_address == 4'h1)"],
  );
  



  e_register->add({
    out         => e_signal->add(["ctl_irq_en_reg", 1]),
    in          => "av_ctl_writedata[3]",
    enable      => "ctl_lo_write_strobe",
    async_value => 0,
   });
   
  e_register->add({
    out         => e_signal->add(["reset_reg", 1]),
    in          => "av_ctl_writedata[2]",
    enable      => "ctl_lo_write_strobe",
    async_value => 0,
   });  
  
  e_register->add({
    out         => e_signal->add(["power_reg", 1]),
    in          => "av_ctl_writedata[1]",
    enable      => "ctl_lo_write_strobe",
    async_value => 0,
   });  
  
  e_register->add({
    out         => e_signal->add(["ide_irq_en_reg", 1]),
    in          => "av_ctl_writedata[0]",
    enable      => "ctl_hi_write_strobe",
    async_value => 0,
   });  
    
  




  my @ctl_reg_zero_bits = ();  
  push (@ctl_reg_zero_bits,
    "ctl_irq_en_reg", 
    "reset_reg", 
    "power_reg", 
    "present_reg",
  );
  
  my @ctl_reg_one_bits = ();
  push (@ctl_reg_one_bits,
    "3'h0",
    "ide_irq_en_reg",
  );
  

  my $ctl_read_mux;
  $ctl_read_mux = e_mux->add({
    lhs     => e_signal->add(["ctl_read_mux", 4]),
    selecto => "av_ctl_address",
    table   => [
      "2'b00" => &concatenate(@ctl_reg_zero_bits),
      "2'b01" => &concatenate(@ctl_reg_one_bits),
      "2'b10" => "4'h0",
      "2'b11" => "4'h0",
      ],
  });


  e_register->add({
    out         => "av_ctl_readdata",
    in          => "ctl_read_mux",
    async_value => 0,
    enable      => 1,
  });



























  my $clock_speed = $project->get_module_clock_frequency();
  my $debounce_count = &ceil($clock_speed / 1000); 
  my $debounce_width = &ceil(&log2($debounce_count));
  

  e_register->add({
    out         => e_signal->add(["present_counter", $debounce_width]),
    in          => "present_counter + 1",
    enable      => 1,
    async_value => 0,
    sync_reset  => "detect_n",
  });
  

  e_register->add({
    out         => e_signal->add(["present_reg", 1]),
    sync_set    => "present_counter == $debounce_count",
    sync_reset  => "detect_n",
    async_value => 0,
    enable      => 1,
  }); 
  

  e_register->add({
    out         => e_signal->add(["d1_present_reg", 1]),
    in          => "present_reg",
    async_value => 0,
    enable      => 1,
  }); 


  e_assign->adds(
    ["ctl_lo_read_strobe", "~av_ctl_chipselect_n && ~av_ctl_read_n && 
      (av_ctl_address == 4'h0)"],
  );



  e_register->add({
    out         => "av_ctl_irq",
    sync_set    => "(d1_present_reg ^ present_reg)",
    sync_reset  => "ctl_lo_read_strobe",
    async_value => 0,
    enable      => "ctl_irq_en_reg",
  });

  e_assign->adds({
      lhs => {name => "reset_n", never_export => 1,},
      rhs => "av_reset_n",
  });
};

qq{
There are strange things done in the midnight sun
By the men who moil for gold,
And the arctic trails have their secret tales
That would make your blood run cold.
The northern lights have seen queer sights,
But the queerest they ever did see
Was the night on the marge of Lake LaBarge
I cremated Sam McGee.

Now, Sam McGee was from Tennessee
Where the cotton blooms and blows.
Why he left his home in the south to roam
’Round the pole, God only knows.
He was always cold, but the land of gold
Seemed to hold him like a spell,
Though he’d often say, in his homely way,
He’d sooner live in hell.

On a Christmas day we were mushing our way
Over the Dawson Trail.
Talk of your cold—through the parka’s fold
It stabbed like a driven nail.
If our eyes we’d close, then the lashes froze
’Till sometimes we couldn’t see.
It wasn’t much fun, but the only one
To whimper was Sam McGee.

And that very night as we lay packed tight
In our robes beneath the snow,
And the dogs were fed, and the stars o’erhead
Were dancing heel and toe,
He turned to me, and “Cap”, says he,
“I’ll cash in this trip, I guess,
And if I do, I’m asking that you
Won’t refuse my last request.”

Well, he seemed so low I couldn’t say no,
And he says with a sort of moan,
“It’s the cursed cold, and it’s got right hold
’Till I’m chilled clean through to the bone.
Yet ’ta’int being dead, it’s my awful dread
Of the icy grave that pains,
So I want you to swear that, foul or fair,
You’ll cremate my last remains.”

A pal’s last need is a thing to heed,
And I swore that I would not fail.
We started on at the streak of dawn,
But, God, he looked ghastly pale.
He crouched on the sleigh, and he raved all day
Of his home in Tennessee,
And before nightfall, a corpse was all
That was left of Sam McGee.

There wasn’t a breath in that land of death
As I hurried, horror driven,
With a corpse half hid that I couldn’t get rid
Because of a promise given.
It was lashed to the sleigh, and it seemed to say,
“You may tax your brawn and brains,
But you promised true, and it’s up to you
To cremate those last remains.”

Now, a promise made is a debt unpaid,
And the trail has its own stern code.
In the days to come, ’though my lips were dumb,
In my heart, how I cursed the load.
In the long, long night by the lone firelight
While the huskies ’round in a ring
Howled out their woes to the homeless snows
Oh, God, how I loathed the thing.

And every day that quiet clay
Seemed to heavy and heavier grow.
And on I went, though the dogs were spent
And the grub was getting low.
The trail was bad, and I felt half mad,
But I swore I would not give in,
And often I’d sing to the hateful thing,
And it hearkened with a grin.

’Till I came to the marge of Lake LaBarge,
And a derelict there lay.
It was jammed in the ice, and I saw in a trice
It was called the “Alice May”.
I looked at it, and I thought a bit,
And I looked at my frozen chum,
Then, “Here”, said I, with a sudden cry,
“Is my crematorium.”

Some planks I tore from the cabin floor
And lit the boiler fire.
Some coal I found that was lying around
And heaped the fuel higher.
The flames just soared, and the furnace roared,
Such a blaze you seldom see.
Then I burrowed a hole in the glowing coal
And I stuffed in Sam McGee.

Then I made a hike, for I didn’t like
To hear him sizzle so.
And the heavens scowled, and the huskies howled,
And the wind began to blow.
It was icy cold, but the hot sweat rolled
Down my cheek, and I don’t know why,
And the greasy smoke in an inky cloak
Went streaking down the sky.

I do not know how long in the snow
I wrestled with gristly fear.
But the stars came out, and they danced about
’Ere again I ventured near.
I was sick with dread, but I bravely said,
“I’ll just take a peek inside.
I guess he’s cooked, and it’s time I looked”,
And the door I opened wide.

And there sat Sam, looking calm and cool
In the heart of the furnace roar.
He wore a smile you could see a mile,
And he said, “Please close that door.
It’s fine in here, but I greatly fear
You’ll let in the cold and storm.
Since I left Plumbtree down in Tennessee
It’s the first time I’ve been warm.”

There are strange things done in the midnight sun
By the men who moil for gold,
And the arctic trails have their secret tales
That would make your blood run cold.
The northern lights have seen queer sights,
But the queerest they ever did see
Was the night on the marge of Lake LaBarge
I cremated Sam McGee.
 - Robert William Service
};


