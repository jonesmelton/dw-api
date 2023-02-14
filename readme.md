# dw-api
A small utility for witchy needs on the [discworld mud](http://discworld.starturtle.net/lpc/).  

Deployed [on fly](https://dw-mud-api.fly.dev)

## Contains:
- A search util for items that can be 'gathered,' which includes most witch tea ingredients.
- A location-filterable search of known npcs that can be flown to.

## Data sources
- The item and room data was extracted from [Quow's](http://quow.co.uk) incredible DB.
- I don't know where I originally got the maps, I've had this set for years, but they look like they came from [Kefka's](https://dw.daftjunk.com) originally.
- NPCs extracted from the [wiki](https://dwwiki.mooo.com/wiki/Fly-tos) and then munged into sqlite with a ruby script that I lost.

## Technical
To a significant extent this is just playing around with some technologies I've been interested in.  


- janet for api backend and db connection.
- sqlite fts5 extension for searching within tables.
- htmx for core UI interactivity and data fetching.
- hyperscript for dom manipulation

### running & using
If you want to run locally you'll need to install `janet` and its build system `jpm`.  

Clone the repo and run `jpm deps`. The janet sqlite driver uses a very basic build, I've forked it to add in the fts5 and json extensions. Also using my fork of suresql because the way it defines queries as global dynamics was causing me problems. If you have other janet packages that depend on either of these this will overwrite your deps because of how jpm works. My forks should be compatible though.

If you want to build a single-file binary you can just `jpm build`. You can also build with docker, which is included because I was having trouble building an x86 binary for fly from my arm machine.

Check `project.janet` for other commands.
