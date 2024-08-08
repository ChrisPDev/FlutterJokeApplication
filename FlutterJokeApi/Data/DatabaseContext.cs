using System.Collections.Generic;
using System.Reflection.Emit;
using FlutterJokeApi.Data;
using FlutterJokeApi.Models;
using Microsoft.EntityFrameworkCore;

namespace FlutterJokeApi.Data
{
    public class DatabaseContext : DbContext
    {
        public DatabaseContext(DbContextOptions<DatabaseContext> options) : base(options) { }
        public DbSet<Joke> Jokes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
        }

    }
}
