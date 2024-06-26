﻿
&ИзменениеИКонтроль("ОбновитьРолиПользователей")
Процедура гф_ОбновитьРолиПользователей(Знач ОписаниеПользователей, Знач ПарольПользователяСервиса, ЕстьИзменения)
	
	Если НЕ ПользователиСлужебный.ЗапретРедактированияРолей() Тогда
		// Роли устанавливаются механизмами подсистем Пользователи и ВнешниеПользователи.
		Возврат;
	КонецЕсли;
	
	Если ОписаниеПользователей = Неопределено Тогда
		МассивПользователей = Неопределено;
		Пользователи.НайтиНеоднозначныхПользователейИБ(Неопределено);
		
	ИначеЕсли ТипЗнч(ОписаниеПользователей) = Тип("Массив") Тогда
		МассивПользователей = ОписаниеПользователей;
		Если МассивПользователей.Количество() = 0 Тогда
			Возврат;
		ИначеЕсли МассивПользователей.Количество() = 1 Тогда
			Пользователи.НайтиНеоднозначныхПользователейИБ(МассивПользователей[0]);
		Иначе
			Пользователи.НайтиНеоднозначныхПользователейИБ(Неопределено);
		КонецЕсли;
		
	ИначеЕсли ТипЗнч(ОписаниеПользователей) = Тип("Тип") Тогда
		МассивПользователей = ОписаниеПользователей;
		Пользователи.НайтиНеоднозначныхПользователейИБ(Неопределено);
	Иначе
		МассивПользователей = Новый Массив;
		МассивПользователей.Добавить(ОписаниеПользователей);
		Пользователи.НайтиНеоднозначныхПользователейИБ(ОписаниеПользователей);
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТекущиеСвойстваПользователей = ТекущиеСвойстваПользователей(МассивПользователей);
	
	// Параметры проверки в цикле.
	ВсеРоли                             = ПользователиСлужебный.ВсеРоли().Соответствие;
	ИдентификаторыПользователейИБ       = ТекущиеСвойстваПользователей.ИдентификаторыПользователейИБ;
	НовыеРолиПользователей              = ТекущиеСвойстваПользователей.РолиПользователей;
	Администраторы                      = ТекущиеСвойстваПользователей.Администраторы;
	РазделениеВключено                  = ОбщегоНазначения.РазделениеВключено();
	НеобходимоОбновлениеИБ              = ОбновлениеИнформационнойБазы.НеобходимоОбновлениеИнформационнойБазы();
	ИдентификаторТекущегоПользователяИБ = ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор;
	
	ОбязательныеРолиАдминистратора = Новый Соответствие;
	ОбязательныеРолиАдминистратора.Вставить("ПолныеПрава", Истина);
	Если Не РазделениеВключено Тогда
		ОбязательныеРолиАдминистратора.Вставить("АдминистраторСистемы", Истина);
	КонецЕсли;
	СтандартныеРолиРасширений = УправлениеДоступомСлужебныйПовтИсп.ОписаниеСтандартныхРолейРасширенийСеанса().РолиСеанса;
	ДополнительныеРолиАдминистратора = Новый Соответствие(СтандартныеРолиРасширений.ДополнительныеРолиАдминистратора);
	ПриПодготовкеДополнительныхРолейАдминистратора(ДополнительныеРолиАдминистратора);
	ДополнительныеРолиАдминистратора.Вставить("ИнтерактивноеОткрытиеВнешнихОтчетовИОбработок", Истина);
	
	// Будущий итог после цикла.
	НовыеАдминистраторыИБ     = Новый Соответствие;
	ОбновляемыеПользователиИБ = Новый Соответствие;
	НекорректныеРоли          = НовыеНекорректныеРоли(НовыеРолиПользователей);
	
	Для Каждого ОписаниеПользователя Из ИдентификаторыПользователейИБ Цикл
		
		ТекущийПользователь         = ОписаниеПользователя.Пользователь;
		ИдентификаторПользователяИБ = ОписаниеПользователя.ИдентификаторПользователяИБ;
		НовыйАдминистраторИБ        = Ложь;
		
		// Поиск пользователя ИБ.
		Если ТипЗнч(ИдентификаторПользователяИБ) = Тип("УникальныйИдентификатор") Тогда
			ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
				ИдентификаторПользователяИБ);
		Иначе
			ПользовательИБ = Неопределено;
		КонецЕсли;
		
		Если ПользовательИБ = Неопределено
		 Или Не ЗначениеЗаполнено(ПользовательИБ.Имя) Тогда
			Продолжить;
		КонецЕсли;
		
		Если НеобходимоОбновлениеИБ
		   И ИдентификаторПользователяИБ = ИдентификаторТекущегоПользователяИБ Тогда
			Продолжить;
		КонецЕсли;
		
		Отказ = Ложь;
		ИнтеграцияПодсистемБСП.ПриОбновленииРолейПользователяИБ(ИдентификаторПользователяИБ, Отказ);
		Если Отказ Тогда
			Продолжить;
		КонецЕсли;
		
		Отбор = Новый Структура("Пользователь", ТекущийПользователь);
		НовыеРоли = НовыеРолиПользователей.Скопировать(
			НовыеРолиПользователей.НайтиСтроки(Отбор), "Роль, РольСсылка");
		
		НовыеРоли.Индексы.Добавить("Роль");
		
		Если Администраторы[ТекущийПользователь] <> Неопределено Тогда
			ТекущиеНовыеРоли = НовыеРоли;
			НовыеРоли = ТекущиеНовыеРоли.Скопировать(Новый Массив);
			Для Каждого КлючИЗначение Из ОбязательныеРолиАдминистратора Цикл
				НовыеРоли.Добавить().Роль = КлючИЗначение.Ключ;
			КонецЦикла;
			Для Каждого КлючИЗначение Из ДополнительныеРолиАдминистратора Цикл
				Если ТекущиеНовыеРоли.Найти(КлючИЗначение.Ключ, "Роль") = Неопределено Тогда
					Продолжить;
				КонецЕсли;
				НовыеРоли.Добавить().Роль = КлючИЗначение.Ключ;
			КонецЦикла;
			#Вставка
			// vvv Галфинд \ Sakovich 02.10.2023
			Для каждого лРоль Из ТекущиеНовыеРоли Цикл
				лОтбор = Новый Структура("Роль", лРоль["Роль"]);
				мСтрокНовыеРоли = НовыеРоли.НайтиСтроки(лОтбор);
				Если мСтрокНовыеРоли.Количество() = 0 Тогда
					лНс = НовыеРоли.Добавить();
					лНс.Роль = лРоль.Роль;
					лНс.РольСсылка = лРоль.РольСсылка;
				КонецЕсли;
			КонецЦикла;
			// ^^^ Галфинд \ Sakovich 02.10.2023
			#КонецВставки
		КонецЕсли;
		
		// Проверка старых ролей.
		СтарыеРоли        = Новый Соответствие;
		РолиДляДобавления = Новый Соответствие;
		РолиДляУдаления   = Новый Соответствие;
		
		Для Каждого Роль Из ПользовательИБ.Роли Цикл
			ИмяРоли = Роль.Имя;
			СтарыеРоли.Вставить(ИмяРоли, Истина);
			Если НовыеРоли.Найти(ИмяРоли, "Роль") = Неопределено Тогда
				РолиДляУдаления.Вставить(ИмяРоли, Роль);
			КонецЕсли;
		КонецЦикла;
		
		НедоступныеРоли = ПользователиСлужебный.НедоступныеРолиПоТипуПользователя(
			ТипЗнч(ТекущийПользователь) = Тип("СправочникСсылка.ВнешниеПользователи"));
		
		// Проверка новых ролей.
		Для Каждого Строка Из НовыеРоли Цикл
			
			Если СтарыеРоли[Строка.Роль] <> Неопределено Тогда
				Если РазделениеВключено
				   И НедоступныеРоли.Получить(Строка.Роль) <> Неопределено Тогда
					ДобавитьНекорректнуюРоль(НекорректныеРоли, Строка, ТекущийПользователь, Ложь);
					РолиДляУдаления.Вставить(Строка.Роль, Истина);
				КонецЕсли;
				Продолжить;
			КонецЕсли;
			
			Если ВсеРоли.Получить(Строка.Роль) = Неопределено Тогда
				ДобавитьНекорректнуюРоль(НекорректныеРоли, Строка, ТекущийПользователь, Истина);
				Продолжить;
			КонецЕсли;
			
			Если НедоступныеРоли.Получить(Строка.Роль) <> Неопределено Тогда
				ДобавитьНекорректнуюРоль(НекорректныеРоли, Строка, ТекущийПользователь, Ложь);
				Продолжить;
			КонецЕсли;
			
			РолиДляДобавления.Вставить(Строка.Роль, Истина);
			
			Если Строка.Роль = "АдминистраторСистемы" Тогда
				НовыйАдминистраторИБ = Истина;
			КонецЕсли;
		КонецЦикла;
		
		// Завершение обработки текущего пользователя.
		Если РолиДляДобавления.Количество() = 0
		   И РолиДляУдаления.Количество()   = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ИзмененияРолей = Новый Структура;
		ИзмененияРолей.Вставить("ПользовательСсылка", ТекущийПользователь);
		ИзмененияРолей.Вставить("ПользовательИБ",     ПользовательИБ);
		ИзмененияРолей.Вставить("РолиДляДобавления",  РолиДляДобавления);
		ИзмененияРолей.Вставить("РолиДляУдаления",    РолиДляУдаления);
		
		Если НовыйАдминистраторИБ Тогда
			НовыеАдминистраторыИБ.Вставить(ТекущийПользователь, ИзмененияРолей);
		Иначе
			ОбновляемыеПользователиИБ.Вставить(ТекущийПользователь, ИзмененияРолей);
		КонецЕсли;
		
		ЕстьИзменения = Истина;
	КонецЦикла;
	
	ЗарегистрироватьНекорректныеРоли(НекорректныеРоли);
	
	// Добавление новых администраторов.
	Если НовыеАдминистраторыИБ.Количество() > 0 Тогда
		ОбновитьРолиПользователейИБ(НовыеАдминистраторыИБ, ПарольПользователяСервиса);
	КонецЕсли;
	
	// Удаление старых администраторов и обновление остальных пользователей.
	Если ОбновляемыеПользователиИБ.Количество() > 0 Тогда
		ОбновитьРолиПользователейИБ(ОбновляемыеПользователиИБ, ПарольПользователяСервиса);
	КонецЕсли;
	
	ОтключитьУВсехРасширенийФлажокИспользоватьОсновныеРолиДляВсехПользователей();
	
КонецПроцедуры
