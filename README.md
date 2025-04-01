# TextToAudio
Powershell module for generating audio from text using [ElevenLabs](https://elevenlabs.io/) 

1. Create configuration with your API Key and voices and save it to config.json
```
{
    "apiKey": "",
    "voices": [
        { "name": "SHE", "id": "XrExE9yKIg1WjnnlVkGX", "alias": "Matilda" },
        { "name": "HE", "id": "TX3LPaxmHKxFdv7VOQHJ", "alias": "Liam" },
        { "name": "ONA", "id": "12CHcREbuPdJY02VY7zT", "alias": "Hanka (beta)" },
        { "name": "ON", "id": "uYFJyGaibp4N2VwYQshk", "alias": "Adam" },
        { "name": "VYPRAVĚČ", "id": "NHv5TpkohJlOhwlTCzJk", "alias": "Pawel" },
        { "name": "IRIS", "id": "12CHcREbuPdJY02VY7zT", "alias": "Hanka (beta)" },
        { "name": "RACHEL", "id": "21m00Tcm4TlvDq8ikWAM", "alias": "Rachel" }
    ]
}
```


2. Import ElvenLabs PS module

```
Import-Module ./ElevenLabs
```


3. Load your configuration

```
$config = Get-Content -Path ./config.json | ConvertFrom-Json
```

4. Create mp3 from your text

- single text
```
Save-TextAsMP3 -Text "Hello world" -ApiKey $config.apiKey -VoiceId "TX3LPaxmHKxFdv7VOQHJ" -Language "english"
``` 

- dialog with voice definition
```
@"
SHE: Could you take out the trash? It's already full.`n
HE: Sure, I'll do it right now.
"@ | Save-TextListAsMP3 -Configuration $config -Language "english" -StartCountFrom 5 -ExportDirectory . 
```

- dialog from text file
```
Get-Content -Path ./input.txt | Save-TextListAsMP3 -Configuration $config -ExportDirectory .  -TextToFileName
```

input.txt example:

```
SHE: Could you take out the trash? It's already full.
HE: Sure, I'll do it right now.
SHE: Not "right now," you said that yesterday, and it's still here.
HE: Okay, I'll take it out immediately.
SHE: And after that, check the shopping list. We're missing some things.
HE: I'll take a look.
SHE: Not just look, go and buy them. Milk, bread, eggs.
HE: Alright, I'll go to the store.
SHE: And please, this time, get the right milk, not the low-fat one.
HE: Got it, whole milk.
SHE: One more thing – did you fix the leaking faucet in the bathroom?
HE: Not yet, but it's on my list.
SHE: It's been on your list for a week. Can you fix it today?
HE: Okay, I'll check it after dinner.
SHE: After dinner, you won’t feel like it. Do it now.
HE: Fine, I’ll do it now.
SHE: Thank you. And when you're done, could you also water the plants?
```

Output:

17 mp3 files:


```
001__Could_you_take_out_the_trash__It_s_already_full_.mp3
002__Sure__I_ll_do_it_right_now_.mp3
003__Not__right_now___you_said_that_yesterday__and_it_s_still_here_.mp3
004__Okay__I_ll_take_it_out_immediately_.mp3
005__And_after_that__check_the_shopping_list__We_re_missing_some_things_.mp3
006__I_ll_take_a_look_.mp3
007__Not_just_look__go_and_buy_them__Milk__bread__eggs_.mp3
008__Alright__I_ll_go_to_the_store_.mp3
009__And_please__this_time__get_the_right_milk__not_the_low_fat_one_.mp3
010__Got_it__whole_milk_.mp3
011__One_more_thing___did_you_fix_the_leaking_faucet_in_the_bathroom_.mp3
012__Not_yet__but_it_s_on_my_list_.mp3
013__It_s_been_on_your_list_for_a_week__Can_you_fix_it_today_.mp3
014__Okay__I_ll_check_it_after_dinner_.mp3
015__After_dinner__you_won_t_feel_like_it__Do_it_now_.mp3
016__Fine__I_ll_do_it_now_.mp3
017__Thank_you__And_when_you_re_done__could_you_also_water_the_plants_.mp3
```

Exported mp3 files can be joined using ffmpeg:
```
ffmpeg -i "concat:$(echo *.mp3 | tr ' ' '|')" -acodec copy output.mp3
```
