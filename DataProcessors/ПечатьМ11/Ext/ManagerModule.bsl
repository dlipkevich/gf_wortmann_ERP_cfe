﻿
&ИзменениеИКонтроль("ЗаполнитьТабличныйДокументМ11")
Процедура гф_ЗаполнитьТабличныйДокументМ11(ТабличныйДокумент, ДанныеДляПечати, ОбъектыПечати)

	ШаблонОшибкиТовары = НСтр("ru = 'В документе %1 отсутствуют товары. Печать М-11 не требуется';
	|en = 'Goods are missing in document %1. Printing of M-11 is not required'");

	ТоварКод = ФормированиеПечатныхФорм.ДополнительнаяКолонкаПечатныхФормДокументов().ИмяКолонки;
	Если Не ЗначениеЗаполнено(ТоварКод) Тогда
		ТоварКод = "Код";
	КонецЕсли;

	Макет = УправлениеПечатью.МакетПечатнойФормы("Обработка.ПечатьМ11.ПФ_MXL_М11");

	ПервыйДокумент = Истина;
	ВыборкаДокументы = ДанныеДляПечати.РезультатПоШапке.Выбрать();
	ВыборкаПоТабличнымЧастям = ДанныеДляПечати.РезультатПоТабличнойЧасти.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	СтруктураОтбора = Новый Структура("Ссылка");

	Пока ВыборкаДокументы.Следующий() Цикл

		СтруктураОтбора.Ссылка = ВыборкаДокументы.Ссылка;
		ВыборкаПоТабличнымЧастям.Сбросить();
		Если НЕ ВыборкаПоТабличнымЧастям.НайтиСледующий(СтруктураОтбора) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ШаблонОшибкиТовары,
			ВыборкаДокументы.Ссылка
			),
			ВыборкаДокументы.Ссылка);
			Продолжить;
		КонецЕсли;

		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;

		ВыборкаПоСкладам = ВыборкаПоТабличнымЧастям.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);

		Пока ВыборкаПоСкладам.Следующий() Цикл

			Если Не ПервыйДокумент Тогда
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			КонецЕсли;
			ПервыйДокумент = Ложь;
			НомерСтраницы   = 1;
			НомерСтроки = 0;

			// Создаем массив для проверки вывода
			МассивВыводимыхОбластей = Новый Массив;

			ОбластьПодвал = Макет.ПолучитьОбласть("Подвал");

			// Вывод шапки.
			ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
			ШтрихкодированиеПечатныхФорм.ВывестиШтрихкодВТабличныйДокумент(ТабличныйДокумент, Макет, ОбластьШапка, ВыборкаДокументы.Ссылка);
			ОбластьШапка.Параметры.Заголовок = НСтр("ru = 'ТРЕБОВАНИЕ-НАКЛАДНАЯ №';
			|en = 'REQUISITION NOTE No.'") + ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(ВыборкаДокументы.Номер, Ложь, Истина);
			ОбластьШапка.Параметры.Заполнить(ВыборкаДокументы);
			ОбластьШапка.Параметры.Заполнить(ВыборкаПоСкладам);
			ОбластьШапка.Параметры.ПредставлениеПодразделения = ВыборкаДокументы.Подразделение;

			СведенияОбОрганизации = ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ВыборкаДокументы.Организация, ВыборкаДокументы.ДатаДокумента);
			ОбластьШапка.Параметры.ПредставлениеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации);
			ОбластьШапка.Параметры.КодОКПО = СведенияОбОрганизации.КодПоОКПО;
			ТабличныйДокумент.Вывести(ОбластьШапка);

			// Выводим заголовок таблицы
			ЗаголовокТаблицы = Макет.ПолучитьОбласть("ЗаголовокТаблицы");
			ТабличныйДокумент.Вывести(ЗаголовокТаблицы);

			ВыборкаПоСтрокам = ВыборкаПоСкладам.Выбрать();
			КоличествоСтрок = ВыборкаПоСтрокам.Количество();
			Пока ВыборкаПоСтрокам.Следующий() Цикл

				Область = Макет.ПолучитьОбласть("Строка");
				Область.Параметры.Заполнить(ВыборкаПоСтрокам);

				НомерСтроки = НомерСтроки + 1;

				МассивВыводимыхОбластей.Очистить();
				МассивВыводимыхОбластей.Добавить(Область);

				Если НомерСтроки = КоличествоСтрок Тогда
					МассивВыводимыхОбластей.Добавить(ОбластьПодвал);
				КонецЕсли;

				Если ТоварКод = "Артикул" Тогда
					Область.Параметры.НоменклатурныйНомер = ВыборкаПоСтрокам.НоменклатурныйНомерАртикул;
				Иначе
					Область.Параметры.НоменклатурныйНомер = ВыборкаПоСтрокам.НоменклатурныйНомерКод;
				КонецЕсли;

				ДопПараметрыПредставлениеНоменклатуры = НоменклатураКлиентСервер.ДополнительныеПараметрыПредставлениеНоменклатурыДляПечати();
				ДопПараметрыПредставлениеНоменклатуры.КодОсновногоЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
				#Вставка
				//++ Галфинд ЕсиповАВ 08.06.2023 Добавление значений в область "счет" на пф
				РазделыУчета = Неопределено;
				
				АналитикаУчета = ВыборкаПоСтрокам.Номенклатура.ГруппаФинансовогоУчета;
				РазделыУчета = РегистрыСведений.ПорядокОтраженияНаСчетахУчета.РазделыУчетаПоАналитикеУчета(АналитикаУчета);
				
				
				
				ПараметрыНастройкиСчетовУчета = НастройкаСчетовУчетаСервер.ПараметрыНастройкиСчетовУчета(РазделыУчета);
				ПараметрыНастройкиСчетовУчета.ИмяГруппыНастроекСчетовУчета = "ГруппаСчетов";
				ПараметрыНастройкиСчетовУчета.ПрефиксЭлементовФормы = "НастройкаСчетовУчета";
				ПараметрыНастройкиСчетовУчета.ПрефиксПутиКДанным = "НастройкаСчетовУчета_";
				ПараметрыНастройкиСчетовУчета.ПрефиксПутиКДаннымРеквизитов = "Объект.";
				
				Если ТипЗнч(АналитикаУчета) = Тип("СправочникСсылка.ГруппыФинансовогоУчетаНоменклатуры") Тогда
					ПараметрыНастройкиСчетовУчета.РазбитьПоРазделамЭлементы = Ложь;
					ПараметрыНастройкиСчетовУчета.СворачиваемыеГруппы.Добавить("Стоимость");
					ПараметрыНастройкиСчетовУчета.СворачиваемыеГруппы.Добавить("Продажи");
					ПараметрыНастройкиСчетовУчета.СворачиваемыеГруппы.Добавить("НДС");
					ПараметрыНастройкиСчетовУчета.СворачиваемыеГруппы.Добавить("Резервы");
					ПараметрыНастройкиСчетовУчета.СворачиваемыеГруппы.Добавить("ТМЦПринятыеНаОтветственноеХранение");
					ПараметрыНастройкиСчетовУчета.СворачиваемыеГруппы.Добавить("МатериалыПринятыеВПереработку");
					ПараметрыНастройкиСчетовУчета.СворачиваемыеГруппы.Добавить("ТоварыПринятыеНаКомиссию");
				КонецЕсли;
				
				МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоСсылке(АналитикаУчета);
				МенеджерОбъекта.ЗаполнитьСоответствиеРеквизитовНастройкиСчетовУчета(ПараметрыНастройкиСчетовУчета.ПутиКРеквизитамАналитики);
				
				СчетаУчета = Новый Массив;
				//
				УникИНД = Новый УникальныйИдентификатор;
				СтруктураПараметров = Новый Структура("СчетУчета", УникИНД);
				ЗаполнитьЗначенияСвойств(СтруктураПараметров,ПараметрыНастройкиСчетовУчета);
				
				Если УникИНД <> СтруктураПараметров["СчетУчета"] Тогда
					Для каждого НастройкаРаздела Из ПараметрыНастройкиСчетовУчета.НастройкиРазделов Цикл
						СчетаРаздела = ОбщегоНазначенияКлиентСервер.ОтмеченныеЭлементы(НастройкаРаздела.Значение.СчетаУчета);
						ОбщегоНазначенияКлиентСервер.ДополнитьМассив(СчетаУчета, СчетаРаздела, Истина);
					КонецЦикла;
					
					СтруктураЗначений = РегистрыСведений.ПорядокОтраженияНаСчетахУчета.СтруктураЗначенийПоАналитикеУчета(АналитикаУчета, СчетаУчета);
					Если СтруктураЗначений.Свойство("СчетУчета_НаСкладе") = Неопределено Тогда
						Область.Параметры.Счет = "";
					Иначе	
						Область.Параметры.Счет = СтруктураЗначений.СчетУчета_НаСкладе;
					КонецЕсли;					
				КонецЕсли;
				//
				//Для каждого НастройкаРаздела Из ПараметрыНастройкиСчетовУчета.НастройкиРазделов Цикл
				//		СчетаРаздела = ОбщегоНазначенияКлиентСервер.ОтмеченныеЭлементы(НастройкаРаздела.Значение.СчетаУчета);
				//		ОбщегоНазначенияКлиентСервер.ДополнитьМассив(СчетаУчета, СчетаРаздела, Истина);
				//КонецЦикла;
	
				//СтруктураЗначений = РегистрыСведений.ПорядокОтраженияНаСчетахУчета.СтруктураЗначенийПоАналитикеУчета(АналитикаУчета, СчетаУчета);
				//Если СтруктураЗначений.Свойство("СчетУчета_НаСкладе") = Неопределено Тогда
				//	Область.Параметры.Счет = "";
				//Иначе	
				//	Область.Параметры.Счет = СтруктураЗначений.СчетУчета_НаСкладе;
				//КонецЕсли;

				//-- Галфинд ЕсиповАВ 08.06.2023
				#КонецВставки

				Область.Параметры.МатериалНаименование = НоменклатураКлиентСервер.ПредставлениеНоменклатурыДляПечати(
				СокрЛП(ВыборкаПоСтрокам.НоменклатураНаименование),
				СокрЛП(ВыборкаПоСтрокам.Характеристика),
				,
				,
				ДопПараметрыПредставлениеНоменклатуры);

				Если НЕ ТабличныйДокумент.ПроверитьВывод(МассивВыводимыхОбластей) Тогда
					НомерСтраницы = НомерСтраницы + 1;
					ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
					СтруктураПараметров = Новый Структура;
					СтруктураПараметров.Вставить("НомерСтраницы", "Страница " + НомерСтраницы);
					ЗаголовокТаблицы.Параметры.Заполнить(СтруктураПараметров);
					ТабличныйДокумент.Вывести(ЗаголовокТаблицы);
				КонецЕсли;

				ТабличныйДокумент.Вывести(Область);

			КонецЦикла;

			// Вывод подвала.
			ОбластьПодвал.Параметры.ДолжностьОтправителя = ВыборкаПоСкладам.ДолжностьКладовщикаОтправителя;
			ОбластьПодвал.Параметры.ФИООтправителя = ФизическиеЛицаУТ.ФамилияИнициалыФизЛица(ВыборкаПоСкладам.КладовщикОтправитель, ВыборкаДокументы.ДатаДокумента);
			ТабличныйДокумент.Вывести(ОбластьПодвал);

		КонецЦикла;

		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, ВыборкаДокументы.Ссылка);

	КонецЦикла;

КонецПроцедуры
