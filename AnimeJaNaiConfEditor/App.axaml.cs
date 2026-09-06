using AnimeJaNaiConfEditor.ViewModels;
using AnimeJaNaiConfEditor.Views;
using Avalonia;
using Avalonia.Controls;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using Avalonia.Threading;
using ReactiveUI.Avalonia;
using ReactiveUI;
using System;
using System.IO;
using System.Threading.Tasks;

namespace AnimeJaNaiConfEditor
{
    public partial class App : Application
    {
        private DispatcherTimer? _chineseLocalizationTimer;

        public override void Initialize()
        {
            AvaloniaXamlLoader.Load(this);
        }

        public override void OnFrameworkInitializationCompleted()
        {
            // Dialog handlers are `async void`, so an exception thrown from one (e.g. a
            // FluentAvalonia dialog bug) is posted to the UI dispatcher and would otherwise
            // crash the whole app. Swallow it here so a single dialog failure degrades to a
            // no-op instead of taking down the Manager.
            Dispatcher.UIThread.UnhandledException += (_, e) => e.Handled = true;
            TaskScheduler.UnobservedTaskException += (_, e) => e.SetObserved();

            if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
            {
                // Some Avalonia controls/bindings do not materialize until the Window is
                // actually attached/opened. Keep the whole native window invisible until
                // that has happened and two zh-CN passes have completed. The first visible
                // frame is therefore Chinese instead of briefly exposing the English XAML.
                var mainWindow = new MainWindow
                {
                    DataContext = new MainWindowViewModel(),
                    Opacity = 0,
                };

                mainWindow.Opened += (_, _) =>
                {
                    ChineseLocalization.Apply(mainWindow);
                    Dispatcher.UIThread.Post(() =>
                    {
                        ChineseLocalization.Apply(mainWindow);
                        mainWindow.Opacity = 1;
                    });
                };

                desktop.MainWindow = mainWindow;

                // Keep a light periodic pass for visual content created/updated after startup
                // (FluentAvalonia dialogs and late-bound status text). Startup itself no longer
                // relies on this timer, so there is no English-to-Chinese flash.
                _chineseLocalizationTimer = new DispatcherTimer
                {
                    Interval = TimeSpan.FromMilliseconds(350),
                };
                _chineseLocalizationTimer.Tick += (_, _) =>
                {
                    foreach (var window in desktop.Windows)
                    {
                        ChineseLocalization.Apply(window);
                    }
                };
                _chineseLocalizationTimer.Start();

                // When another launch (e.g. a repeated Ctrl+E from mpv) signals this instance,
                // bring the existing window to the front instead of opening a new one.
                Program.ActivationRequested += () => BringToFront(desktop.MainWindow);
            }

            base.OnFrameworkInitializationCompleted();
        }

        private static void BringToFront(Window? window)
        {
            if (window is null)
            {
                return;
            }

            if (window.WindowState == WindowState.Minimized)
            {
                window.WindowState = WindowState.Normal;
            }

            window.Show();
            window.Activate();
        }
    }
}
