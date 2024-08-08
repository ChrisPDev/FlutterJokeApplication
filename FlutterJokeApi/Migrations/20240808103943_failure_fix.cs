using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FlutterJokeApi.Migrations
{
    /// <inheritdoc />
    public partial class failure_fix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "Jokes",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Content",
                table: "Jokes",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Title",
                table: "Jokes",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Category",
                table: "Jokes");

            migrationBuilder.DropColumn(
                name: "Content",
                table: "Jokes");

            migrationBuilder.DropColumn(
                name: "Title",
                table: "Jokes");
        }
    }
}
