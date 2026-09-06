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
                desktop.MainWindow = new MainWindow
                {
                    DataContext = new MainWindowViewModel(),
                };

                // Personal zh-CN build: keep translating the active visual tree.  A short
                // periodic pass also catches FluentAvalonia dialogs and status strings that
                // are created/updated after startup, while SetCurrentValue in the translator
                // keeps the original Avalonia bindings intact.
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

                Dispatcher.UIThread.Post(() => ChineseLocalization.Apply(desktop.MainWindow));

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
