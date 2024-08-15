using Microsoft.AspNetCore.Mvc;
using FlutterJokeApi.Models;
using FlutterJokeApi.Data;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace FlutterJokeApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class JokesController : ControllerBase
    {
        private readonly DatabaseContext _context;

        public JokesController(DatabaseContext context)
        {
            _context = context;
        }

        // EP 1: Get all jokes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Joke>>> GetAllJokes()
        {
            var jokes = await _context.Jokes.ToListAsync();
            return Ok(jokes);
        }

        // EP 2: Get all jokes sorted by category
        [HttpGet("sorted")]
        public async Task<ActionResult<IEnumerable<Joke>>> GetAllJokesSortedByCategory()
        {
            var jokes = await _context.Jokes.OrderBy(j => j.Category).ToListAsync();
            return Ok(jokes);
        }

        // EP 3: Get specific joke
        [HttpGet("{id}")]
        public async Task<ActionResult<Joke>> GetJoke(int id)
        {
            var joke = await _context.Jokes.FindAsync(id);
            if (joke == null)
            {
                return NotFound();
            }
            return Ok(joke);
        }

        // EP 4: Get all jokes within a specific category
        [HttpGet("category/{category}")]
        public async Task<ActionResult<IEnumerable<Joke>>> GetJokesByCategory(string category)
        {
            var jokes = await _context.Jokes
                .Where(j => j.Category.Equals(category, System.StringComparison.OrdinalIgnoreCase))
                .ToListAsync();

            if (!jokes.Any())
            {
                return NotFound();
            }
            return Ok(jokes);
        }

        // EP 5: Get a random joke
        [HttpGet("random")]
        public async Task<ActionResult<Joke>> GetRandomJoke()
        {
            var jokesCount = await _context.Jokes.CountAsync();
            if (jokesCount == 0)
            {
                return NotFound();
            }

            var random = new System.Random();
            var joke = await _context.Jokes
                .Skip(random.Next(jokesCount))
                .FirstOrDefaultAsync();

            return Ok(joke);
        }

        // EP 6: Get a random joke within a specific category
        [HttpGet("random/category/{category}")]
        public async Task<ActionResult<Joke>> GetRandomJokeByCategory(string category)
        {
            var jokes = await _context.Jokes
                .Where(j => j.Category.Equals(category, System.StringComparison.OrdinalIgnoreCase))
                .ToListAsync();

            if (!jokes.Any())
            {
                return NotFound();
            }

            var random = new System.Random();
            var joke = jokes[random.Next(jokes.Count)];
            return Ok(joke);
        }

        // EP 7: Create a new joke
        [HttpPost]
        public async Task<ActionResult<Joke>> CreateJoke([FromBody] Joke newJoke)
        {
            if (newJoke == null)
            {
                return BadRequest();
            }

            newJoke.CreatedAt = System.DateTime.UtcNow.AddHours(2);
            newJoke.UpdatedAt = System.DateTime.UtcNow.AddHours(2);

            _context.Jokes.Add(newJoke);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetJoke), new { id = newJoke.Id }, newJoke);
        }

        // EP 8: Update a specific joke
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateJoke(int id, [FromBody] Joke updatedJoke)
        {
            if (id != updatedJoke.Id)
            {
                return BadRequest();
            }

            var joke = await _context.Jokes.FindAsync(id);
            if (joke == null)
            {
                return NotFound();
            }

            joke.Title = updatedJoke.Title;
            joke.Content = updatedJoke.Content;
            joke.Category = updatedJoke.Category;
            joke.UpdatedAt = System.DateTime.UtcNow.AddHours(2);

            _context.Entry(joke).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // EP 9: Delete a specific joke
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteJoke(int id)
        {
            var joke = await _context.Jokes.FindAsync(id);
            if (joke == null)
            {
                return NotFound();
            }

            _context.Jokes.Remove(joke);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
