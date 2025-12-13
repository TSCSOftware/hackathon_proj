package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/examples/base/Functions"
	"github.com/pocketbase/pocketbase/examples/base/livekit_pkg"
	"github.com/pocketbase/pocketbase/plugins/ghupdate"
	"github.com/pocketbase/pocketbase/plugins/jsvm"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
	"github.com/pocketbase/pocketbase/tools/hook"
	"github.com/pocketbase/pocketbase/tools/osutils"
)

func main() {
	app := pocketbase.New()

	// ---------------------------------------------------------------
	// Optional plugin flags:
	// ---------------------------------------------------------------

	var hooksDir string
	app.RootCmd.PersistentFlags().StringVar(
		&hooksDir,
		"hooksDir",
		os.Getenv("PB_HOOKS_DIR"),
		"the directory with the JS app hooks",
	)

	var hooksWatch bool
	app.RootCmd.PersistentFlags().BoolVar(
		&hooksWatch,
		"hooksWatch",
		true,
		"auto restart the app on pb_hooks file change; it has no effect on Windows",
	)

	var hooksPool int
	app.RootCmd.PersistentFlags().IntVar(
		&hooksPool,
		"hooksPool",
		15,
		"the total prewarm goja.Runtime instances for the JS app hooks execution",
	)

	var migrationsDir string
	app.RootCmd.PersistentFlags().StringVar(
		&migrationsDir,
		"migrationsDir",
		"",
		"the directory with the user defined migrations",
	)

	var automigrate bool
	app.RootCmd.PersistentFlags().BoolVar(
		&automigrate,
		"automigrate",
		true,
		"enable/disable auto migrations",
	)

	var publicDir string
	app.RootCmd.PersistentFlags().StringVar(
		&publicDir,
		"publicDir",
		defaultPublicDir(),
		"the directory to serve static files",
	)

	var indexFallback bool
	app.RootCmd.PersistentFlags().BoolVar(
		&indexFallback,
		"indexFallback",
		true,
		"fallback the request to index.html on missing static path, e.g. when pretty urls are used with SPA",
	)

	app.RootCmd.ParseFlags(os.Args[1:])

	// ---------------------------------------------------------------
	// Plugins and hooks:
	// ---------------------------------------------------------------

	// load jsvm (pb_hooks and pb_migrations)
	jsvm.MustRegister(app, jsvm.Config{
		MigrationsDir: migrationsDir,
		HooksDir:      hooksDir,
		HooksWatch:    hooksWatch,
		HooksPoolSize: hooksPool,
	})

	// migrate command (with js templates)
	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		TemplateLang: migratecmd.TemplateLangJS,
		Automigrate:  automigrate,
		Dir:          migrationsDir,
	})

	// GitHub selfupdate
	ghupdate.MustRegister(app, app.RootCmd, ghupdate.Config{})

	// static route to serves files from the provided public dir
	// (if publicDir exists and the route path is not already defined)
	app.OnServe().Bind(&hook.Handler[*core.ServeEvent]{
		Func: func(e *core.ServeEvent) error {
			if !e.Router.HasRoute(http.MethodGet, "/{path...}") {
				e.Router.GET("/{path...}", apis.Static(os.DirFS(publicDir), indexFallback))
			}

			return e.Next()
		},
		Priority: 999, // execute as latest as possible to allow users to provide their own route
	})

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// register "GET /hello/{name}" route (allowed for everyone)
		se.Router.GET("/api/get_slots", func(e *core.RequestEvent) error {

			provider := e.Request.URL.Query().Get("providerid")
			date := e.Request.URL.Query().Get("date")
			service := e.Request.URL.Query().Get("service")
			data := Functions.GetSlots(app, provider, date, service)

			return e.String(http.StatusOK, data)
		}).Bind(apis.RequireAuth())

		se.Router.GET("/test", func(e *core.RequestEvent) error {

			// date := e.Request.URL.Query().Get("date")

			Functions.Gen_next_slots(app)

			return e.String(http.StatusOK, "")
		}).Bind(apis.RequireAuth())
		se.Router.POST("/api/book_appointment", func(e *core.RequestEvent) error {

			// date := e.Request.URL.User.Username()
			println(e.Auth.Id)
			// Functions.Gen_next_slots(app)

			return e.String(http.StatusOK, "")
		}).Bind(apis.RequireAuth())

		se.Router.POST("/rtc/{rtc_path}", func(e *core.RequestEvent) error {
			rtc_path := e.Request.PathValue("rtc_path")

			// do something ...
			return livekit_pkg.Rtc_handler(e, rtc_path)
			//  e.JSON(http.StatusOK, map[string]bool{"success": true})

		}).Bind(apis.RequireAuth())

		return se.Next()
	})

	app.Cron().MustAdd("Delete_old_slots", "0 0 * * *", func() {
		Functions.Del_old_slots(app)
	})

	app.Cron().MustAdd("Gen_next_slots_for_one_day", "0 0 * * *", func() {
		Functions.Gen_next_slots(app)
	})
	//
	livekit_pkg.Init_livekit(context.Background())

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}

}

// the default pb_public dir location is relative to the executable
func defaultPublicDir() string {
	if os.Getenv("PB_PUBLIC_DIR") != "" {
		return os.Getenv("PB_PUBLIC_DIR")
	}
	if osutils.IsProbablyGoRun() {
		return "./pb_public"
	}

	return filepath.Join(os.Args[0], "../pb_public")
}
