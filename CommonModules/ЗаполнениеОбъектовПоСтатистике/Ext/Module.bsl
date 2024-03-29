﻿
&ИзменениеИКонтроль("УстановитьАвтораОбъектаПередЗаписью")
Процедура гф_УстановитьАвтораОбъектаПередЗаписью(Источник, Отказ, РежимЗаписи, РежимПроведения)

	Если Источник.ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	#Вставка
	// ++ Галфинд ВолковЕВ 29.08.2023
	// При автоматическом создании Реализации автор наследуется из Ордера и перезапись не требуется
	Если ТипЗнч(Источник) = Тип("ДокументОбъект.РеализацияТоваровУслуг")
		И Источник.ДополнительныеСвойства.Свойство("гф_НеИспользоватьПерезаписьАвтора", Истина) Тогда
		Возврат;
	КонецЕсли;
	// -- Галфинд ВолковЕВ 29.08.2023
	#КонецВставки

	Если Не ЗначениеЗаполнено(Источник.Ссылка) Тогда
		Источник.Автор = Пользователи.АвторизованныйПользователь();
	КонецЕсли;

КонецПроцедуры
