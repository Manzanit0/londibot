# https://hexdocs.pm/mox/Mox.html#module-compile-time-requirements
Mox.defmock(Londibot.TFLMock, for: Londibot.TFLBehaviour)
Mox.defmock(Londibot.NotifierMock, for: Londibot.Notifier)
Mox.defmock(Londibot.SubscriptionStoreMock, for: Londibot.StoreBehaviour)
