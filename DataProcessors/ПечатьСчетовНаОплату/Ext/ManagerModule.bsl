﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

&ИзменениеИКонтроль("ЗаполнитьТабличныйДокументСчетаНаОплату")
Процедура гф_ЗаполнитьТабличныйДокументСчетаНаОплату(ТабличныйДокумент, ДанныеДляПечати, ОбъектыПечати, ПараметрыПечати)

	ШаблоныОшибок = Новый Структура;
	ШаблоныОшибок.Вставить("Товары", НСтр("ru = 'В документе %1 отсутствуют товары. Печать счета на оплату не требуется';
	|en = 'Goods are missing in the %1 document. It is not required to print the commercial invoice'"));
	ШаблоныОшибок.Вставить("ЗаменяющиеТовары", НСтр("ru = 'В документе %1 отсутствуют заменяющие товары. Печать счета на оплату не требуется';
	|en = 'Substitute goods are missing in the %1 document. It is not required to print the commercial invoice'"));
	ШаблоныОшибок.Вставить("Этапы", НСтр("ru = 'В документе %1 отсутствуют этапы оплаты. Печать счета на оплату не требуется';
	|en = 'Payment steps are missing in the %1 document. It is not required to print the commercial invoice'"));

	ИспользуетсяУчетНДС = ПолучитьФункциональнуюОпцию("ИспользоватьУчетНДС");
	ИспользоватьРучныеСкидки         = ПолучитьФункциональнуюОпцию("ИспользоватьРучныеСкидкиВПродажах");
	ИспользоватьАвтоматическиеСкидки = ПолучитьФункциональнуюОпцию("ИспользоватьАвтоматическиеСкидкиВПродажах");

	КолонкаКодов = ФормированиеПечатныхФорм.ДополнительнаяКолонкаПечатныхФормДокументов();
	ИмяКолонкиКодов = КолонкаКодов.ИмяКолонки;
	ПредставлениеКолонкиКодов = КолонкаКодов.ПредставлениеКолонки;

	СтруктураИмяДопКолонки = Новый Структура("ИмяКолонкиКодов, ПредставлениеКолонкиКодов", ИмяКолонкиКодов, ПредставлениеКолонкиКодов);

	ДанныеПечати = ДанныеДляПечати.РезультатПоШапке.Выбрать();
	ЭтапыОплаты = ДанныеДляПечати.РезультатПоЭтапамОплаты.Выгрузить();
	Товары = ДанныеДляПечати.РезультатПоТабличнойЧасти.Выгрузить();

	ЭтапыЗалоговойТары = ЭтапыОплаты.НайтиСтроки(Новый Структура("ЭтоЗалогЗаТару", Истина));
	ТолькоЗалогЗаТару = ЭтапыЗалоговойТары.Количество() = ЭтапыОплаты.Количество() И ЭтапыЗалоговойТары.Количество() > 0;

	Если Товары.Колонки.Найти("Содержание")=Неопределено Тогда
		ЕстьСодержание = Ложь;
	Иначе
		ЕстьСодержание = Истина;
	КонецЕсли;

	ПоказыватьНДС = Константы.ВыводитьДопКолонкиНДС.Получить();
	ПервыйДокумент = Истина;

	Пока ДанныеПечати.Следующий() Цикл

		Отказ = Ложь;

		СтруктураПоиска = Новый Структура("Ссылка", ДанныеПечати.Ссылка);

		ИспользоватьНаборы = Ложь;
		Если Товары.Колонки.Найти("ЭтоНабор") <> Неопределено Тогда
			ИспользоватьНаборы = Истина;
		КонецЕсли;
		
		#Вставка
		гф_ЗаполнитьТаблицуТоваров(Товары, ДанныеПечати.Ссылка);
		#КонецВставки
		ТаблицаТовары = Товары.НайтиСтроки(СтруктураПоиска);
		ТаблицаЭтапыОплаты = ЭтапыОплаты.НайтиСтроки(СтруктураПоиска);

		ПроверкаЗаполненияДокумента(ДанныеПечати, ТаблицаТовары, ТаблицаЭтапыОплаты, ШаблоныОшибок, Отказ, Истина);
		Если Отказ Тогда
			Продолжить;
		КонецЕсли;

		Если ПервыйДокумент Тогда
			ПервыйДокумент = Ложь;
		Иначе
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;

		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;

		ЗаголовокСкидки = ФормированиеПечатныхФорм.НужноВыводитьСкидки(ТаблицаТовары, ИспользоватьРучныеСкидки Или ИспользоватьАвтоматическиеСкидки);
		ЕстьСкидки = ЗаголовокСкидки.ЕстьСкидки;

		НазванияОбластей = НазванияОбластей(ДанныеПечати.УчитыватьНДС И НЕ ТолькоЗалогЗаТару И ПоказыватьНДС, ЕстьСкидки);

		Макет = Новый ТабличныйДокумент;
		#Вставка
		// Галфинд СадомцевСА 01.02.2024 Расположил факсимиле рядом с подписями см. макет гф_ПФ_MXL_СчетНаОплату
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec03fe158164d
		Если ПараметрыПечати.Свойство("ОтображатьПодписи") Тогда
			Макет = УправлениеПечатью.МакетПечатнойФормы("Обработка.ПечатьСчетовНаОплату.гф_ПФ_MXL_СчетНаОплату");
		КонецЕсли;
		#КонецВставки
		ЗаполнитьРеквизитыШапкиСчетаНаОплату(ДанныеПечати, Макет, ТабличныйДокумент, ТаблицаЭтапыОплаты, ТаблицаТовары);

		Если ДанныеПечати.ЧастичнаяОплата ИЛИ ТипЗнч(ДанныеПечати.ДокументОснование) = Тип("ДокументСсылка.ОтчетКомитенту") Тогда

			ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицыЧастичнаяОплата");
			ТабличныйДокумент.Вывести(ОбластьШапкаТаблицы);

			ОбластьСтрокаТаблицы = Макет.ПолучитьОбласть("СтрокаТаблицыЧастичнаяОплата");
			ОбластьСтрокаТаблицы.Параметры.Заполнить(ДанныеПечати);
			ОбластьСтрокаТаблицы.Параметры.НомерСтроки = 1;
			ТабличныйДокумент.Вывести(ОбластьСтрокаТаблицы);

			ОбластьИтого = Макет.ПолучитьОбласть("ПодвалТаблицыЧастичнаяОплата");
			СтруктураДанныхИтого = Новый Структура;
			СтруктураДанныхИтого.Вставить("Всего", ДанныеПечати.СуммаДокумента);
			ОбластьИтого.Параметры.Заполнить(СтруктураДанныхИтого);
			ОбластьИтого.Параметры.Заполнить(ДанныеПечати);
			ТабличныйДокумент.Присоединить(ОбластьИтого);

			// Вывести ИтогоНДС
			СоответствиеСтавокНДС = Новый Соответствие;
			Если ДанныеПечати.УчитыватьНДС И НЕ ТолькоЗалогЗаТару 
				И НЕ ДанныеПечати.ОперацияОблагаетсяНДСУПокупателя Тогда
				ОбластьИтогоНДС = Макет.ПолучитьОбласть("ПодвалТаблицыНДС");

				Если ТаблицаТовары.Количество() = 0 Тогда
					Если ЗначениеЗаполнено(ДанныеПечати.СтавкаНДС) Тогда
						СуммаНДС = ДанныеПечати.СуммаНДС;
						СоответствиеСтавокНДС.Вставить(ДанныеПечати.СтавкаНДС, СуммаНДС);
					КонецЕсли;
				Иначе
					Для Каждого СтрокаТовара Из ТаблицаТовары Цикл
						Если ИспользоватьНаборы И СтрокаТовара.ЭтоНабор
							И Не (СтрокаТовара.ВариантПредставленияНабораВПечатныхФормах = 
							Перечисления.ВариантыПредставленияНаборовВПечатныхФормах.ТолькоНабор) Тогда
							// Исключаем суммы НДС по набору в целом, когда комплектующие выводятся в печатных формах.
							Продолжить;
						КонецЕсли;
						СуммаНДС = СоответствиеСтавокНДС[СтрокаТовара.СтавкаНДС];
						Если СуммаНДС = Неопределено Тогда
							СуммаНДС = СтрокаТовара.СуммаНДС;
						Иначе
							СуммаНДС = СуммаНДС + СтрокаТовара.СуммаНДС;
						КонецЕсли;
						СоответствиеСтавокНДС.Вставить(СтрокаТовара.СтавкаНДС, СуммаНДС);
					КонецЦикла;
				КонецЕсли;
				Если СоответствиеСтавокНДС.Количество() > 0 Тогда
					Для Каждого ТекСтавкаНДС Из СоответствиеСтавокНДС Цикл
						СтруктураДанныхИтогоНДС = Новый Структура;
						СтруктураДанныхИтогоНДС.Вставить("НДС", ФормированиеПечатныхФорм.ТекстНДСПоСтавке(ТекСтавкаНДС.Ключ, ДанныеПечати.ЦенаВключаетНДС));
						Если ЗначениеЗаполнено(ТекСтавкаНДС.Значение) Тогда
							СтруктураДанныхИтогоНДС.Вставить("ВсегоНДС", ФормированиеПечатныхФорм.ФорматСумм(ТекСтавкаНДС.Значение /100 * ДанныеПечати.ПроцентОплаты));
						Иначе
							СтруктураДанныхИтогоНДС.Вставить("ВсегоНДС","-");
						КонецЕсли;
						ОбластьИтогоНДС.Параметры.Заполнить(СтруктураДанныхИтогоНДС);
						ТабличныйДокумент.Вывести(ОбластьИтогоНДС);
					КонецЦикла;
					ОбластьПодвалСНДС = Макет.ПолучитьОбласть("ПодвалТаблицыВсего");
					СтруктураДанныхПодвалСНДС = Новый Структура("ВсегоСНДС", ФормированиеПечатныхФорм.ФорматСумм(ДанныеПечати.СуммаДокумента));
					ОбластьПодвалСНДС.Параметры.Заполнить(СтруктураДанныхПодвалСНДС);
					ТабличныйДокумент.Вывести(ОбластьПодвалСНДС);
				КонецЕсли;
			ИначеЕсли ИспользуетсяУчетНДС Тогда
				СтруктураДанныхПодвалНДС = Новый Структура;
				Если ДанныеПечати.ОперацияОблагаетсяНДСУПокупателя Тогда
					СтруктураДанныхПодвалНДС.Вставить("НДС", НСтр("ru = 'НДС исчисляется налоговым агентом';
					|en = 'VAT is calculated by tax agent'", ОбщегоНазначения.КодОсновногоЯзыка()));
				Иначе
					СтруктураДанныхПодвалНДС.Вставить("НДС", НСтр("ru = 'Без налога (НДС)';
					|en = 'Without tax (VAT)'", ОбщегоНазначения.КодОсновногоЯзыка()));
				КонецЕсли;
				ОбластьПодвалНДС             = Макет.ПолучитьОбласть("ПодвалТаблицыНДС");
				СтруктураДанныхПодвалНДС.Вставить("ВсегоНДС", "-");
				ОбластьПодвалНДС.Параметры.Заполнить(СтруктураДанныхПодвалНДС);
				ТабличныйДокумент.Вывести(ОбластьПодвалНДС);
			КонецЕсли;

			// Вывести Сумму прописью
			ОбластьМакета = Макет.ПолучитьОбласть("СуммаПрописьюЧастичныйСчет");
			СуммаПрописью = НСтр("ru = 'Всего на сумму %СуммаПрописью%';
			|en = 'Total in the amount of %СуммаПрописью%'", ОбщегоНазначения.КодОсновногоЯзыка());
			СуммаПрописью = СтрЗаменить(СуммаПрописью, "%СуммаПрописью%", РаботаСКурсамиВалютУТ.СформироватьСуммуПрописью(ДанныеПечати.СуммаДокумента, ДанныеПечати.Валюта));
			СтруктураДанныхСуммаПрописью = Новый Структура("СуммаПрописью", СуммаПрописью);
			ОбластьМакета.Параметры.Заполнить(СтруктураДанныхСуммаПрописью);
			ТабличныйДокумент.Вывести(ОбластьМакета);

		Иначе

			// Таблица "Товары"
			ОбластьШапкаТаблицы          = Макет.ПолучитьОбласть(НазванияОбластей.ШапкаТаблицы);
			ОбластьСтрокаТаблицыСтандарт = Макет.ПолучитьОбласть(НазванияОбластей.СтрокаТаблицы);
			ОбластьПодвалТаблицы         = Макет.ПолучитьОбласть(НазванияОбластей.ПодвалТаблицы);
			ОбластьПодвалНДС             = Макет.ПолучитьОбласть("ПодвалТаблицыНДС");

			Если ИспользоватьНаборы Тогда
				ОбластьСтрокаТаблицыНабор         = Макет.ПолучитьОбласть(НазванияОбластей.СтрокаТаблицыНабор);
				ОбластьСтрокаТаблицыКомплектующие = Макет.ПолучитьОбласть(НазванияОбластей.СтрокаТаблицыКомплектующие);
			КонецЕсли;

			ПустыеДанные = НаборыСервер.ПустыеДанные();
			ВыводШапки = 0;

			Если ДанныеПечати.УчитыватьНДС И НЕ ТолькоЗалогЗаТару Тогда
				Если ЕстьСкидки Тогда
					ОбластьПодвалСНДС = Макет.ПолучитьОбласть("ПодвалТаблицыВсегоСНДССоСкидкой");
				Иначе
					ОбластьПодвалСНДС = Макет.ПолучитьОбласть("ПодвалТаблицыВсегоСНДС");
				КонецЕсли
			КонецЕсли;

			Если ЕстьСкидки Тогда
				СтруктураЗаголовокСкидки = Новый Структура("Скидка, СуммаБезСкидки", 
				ЗаголовокСкидки.Скидка,
				ЗаголовокСкидки.СуммаСкидки);
				ОбластьШапкаТаблицы.Параметры.Заполнить(СтруктураЗаголовокСкидки);
			КонецЕсли; 
			ОбластьШапкаТаблицы.Параметры.Заполнить(СтруктураИмяДопКолонки);
			ОбластьСуммаПрописью = Макет.ПолучитьОбласть(?(ДанныеПечати.СчетКВозврату, "СуммаПрописьюКВозврату", "СуммаПрописью"));

			МассивПроверкиВывода = Новый Массив;

			Сумма = 0;
			СуммаНДС = 0;
			ВсегоСкидок = 0;
			ВсегоБезСкидок = 0;
			НомерСтроки = 0;
			СоответствиеСтавокНДС = Новый Соответствие;
			Для Каждого СтрокаТовары Из ТаблицаТовары Цикл

				Если НаборыСервер.ИспользоватьОбластьНабор(СтрокаТовары, ИспользоватьНаборы) Тогда
					ОбластьСтрокаТаблицы = ОбластьСтрокаТаблицыНабор;
				ИначеЕсли НаборыСервер.ИспользоватьОбластьКомплектующие(СтрокаТовары, ИспользоватьНаборы) Тогда
					ОбластьСтрокаТаблицы = ОбластьСтрокаТаблицыКомплектующие;
				Иначе
					ОбластьСтрокаТаблицы = ОбластьСтрокаТаблицыСтандарт;
				КонецЕсли;

				Если НаборыСервер.ВыводитьТолькоЗаголовок(СтрокаТовары, ИспользоватьНаборы) Тогда
					НомерСтрокиПечать = "";
				Иначе
					НомерСтроки = НомерСтроки + 1;
					НомерСтрокиПечать = НомерСтроки;
				КонецЕсли;

				Если НомерСтроки = 0 И ВыводШапки <> 2 Тогда
					ВыводШапки = 1;
				КонецЕсли;

				ПрефиксИПостфикс = НаборыСервер.ПолучитьПрефиксИПостфикс(СтрокаТовары, ИспользоватьНаборы);

				ДополнительныеПараметрыПолученияНаименованияДляПечати = НоменклатураКлиентСервер.ДополнительныеПараметрыПредставлениеНоменклатурыДляПечати();
				ДополнительныеПараметрыПолученияНаименованияДляПечати.ВозвратнаяТара = СтрокаТовары.ЭтоВозвратнаяТара;
				ДополнительныеПараметрыПолученияНаименованияДляПечати.КодОсновногоЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
				Если ЕстьСодержание Тогда
					ДополнительныеПараметрыПолученияНаименованияДляПечати.Содержание = СтрокаТовары.Содержание;
				КонецЕсли;

				Товар = ПрефиксИПостфикс.Префикс
				+ НоменклатураКлиентСервер.ПредставлениеНоменклатурыДляПечати(
				СтрокаТовары.НаименованиеПолное,
				СтрокаТовары.Характеристика,
				,
				, // Серия
				ДополнительныеПараметрыПолученияНаименованияДляПечати)
				+ ПрефиксИПостфикс.Постфикс;

				СтруктураДанныхСтроки = Новый Структура;
				СтруктураДанныхСтроки.Вставить("Товар", Товар);
				СтруктураДанныхСтроки.Вставить("НомерСтроки", НомерСтрокиПечать);
				ОбластьСтрокаТаблицы.Параметры.Заполнить(СтрокаТовары);
				Если ЗаголовокСкидки.ЕстьСкидки Тогда
					СтруктураДанныхСтроки.Вставить("СуммаСкидки",
					?(ЗаголовокСкидки.ТолькоНаценка,- СтрокаТовары.СуммаСкидки,СтрокаТовары.СуммаСкидки));
				КонецЕсли;

				Если ЗначениеЗаполнено(СтруктураИмяДопКолонки.ИмяКолонкиКодов) Тогда
					СтруктураДанныхСтроки.Вставить("Артикул", СтрокаТовары[СтруктураИмяДопКолонки.ИмяКолонкиКодов]);
				КонецЕсли;

				Если ДанныеПечати.ОперацияОблагаетсяНДСУПокупателя Тогда
					СтруктураДанныхСтроки.Вставить("СтавкаНДС", НСтр("ru = 'НДС исчисляется налоговым агентом';
					|en = 'VAT is calculated by tax agent'", ОбщегоНазначения.КодОсновногоЯзыка()));
				КонецЕсли;

				ОбластьСтрокаТаблицы.Параметры.Заполнить(СтруктураДанныхСтроки);

				Если НаборыСервер.ВыводитьТолькоЗаголовок(СтрокаТовары, ИспользоватьНаборы) Тогда
					ОбластьСтрокаТаблицы.Параметры.Заполнить(ПустыеДанные);
				КонецЕсли;

				МассивПроверкиВывода.Очистить();
				МассивПроверкиВывода.Добавить(ОбластьСтрокаТаблицы);
				Если НомерСтроки = ТаблицаТовары.Количество() Тогда
					МассивПроверкиВывода.Добавить(ОбластьПодвалТаблицы);
					МассивПроверкиВывода.Добавить(ОбластьПодвалНДС);
					МассивПроверкиВывода.Добавить(ОбластьСуммаПрописью);
				КонецЕсли;

				Если ТабличныйДокумент.ПроверитьВывод(МассивПроверкиВывода) Тогда
					Если (НомерСтроки = 1 И ВыводШапки = 0) ИЛИ (НомерСтроки = 0 И ВыводШапки = 1) Тогда
						ВыводШапки = 2;
						ТабличныйДокумент.Вывести(ОбластьШапкаТаблицы);
					КонецЕсли;
				Иначе
					ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
					ТабличныйДокумент.Вывести(ОбластьШапкаТаблицы);
				КонецЕсли;

				ТабличныйДокумент.Вывести(ОбластьСтрокаТаблицы);

				Если Не НаборыСервер.ИспользоватьОбластьКомплектующие(СтрокаТовары, ИспользоватьНаборы) Тогда

					Сумма = Сумма + СтрокаТовары.Сумма;
					СуммаНДС = СуммаНДС + СтрокаТовары.СуммаНДС;

					Если ЕстьСкидки Тогда
						ВсегоСкидок = ВсегоСкидок + СтрокаТовары.СуммаСкидки;
						ВсегоБезСкидок = ВсегоБезСкидок + СтрокаТовары.СуммаБезСкидки;
					КонецЕсли;

					Если ДанныеПечати.УчитыватьНДС И НЕ ТолькоЗалогЗаТару Тогда
						СуммаНДСПоСтавке = СоответствиеСтавокНДС[СтрокаТовары.СтавкаНДС];
						Если СуммаНДСПоСтавке = Неопределено Тогда
							СуммаНДСПоСтавке = 0;
						КонецЕсли;
						СоответствиеСтавокНДС.Вставить(СтрокаТовары.СтавкаНДС, СуммаНДСПоСтавке + СтрокаТовары.СуммаНДС);
					КонецЕсли;

				КонецЕсли;

			КонецЦикла;

			СтруктураДанныхВсегоСкидки = Новый Структура;

			// Подвал таблицы "Товары"
			Если ЕстьСкидки Тогда
				СтруктураДанныхВсегоСкидки.Вставить("ВсегоСкидок", ?(ЗаголовокСкидки.ТолькоНаценка,-ВсегоСкидок, ВсегоСкидок));
				СтруктураДанныхВсегоСкидки.Вставить("ВсегоБезСкидок", ВсегоБезСкидок);
				Если ДанныеПечати.УчитыватьНДС И НЕ ТолькоЗалогЗаТару Тогда
					СтруктураДанныхВсегоСкидки.Вставить("ВсегоСуммаНДС", СуммаНДС);
				КонецЕсли;
			КонецЕсли;
			СтруктураДанныхВсегоСкидки.Вставить("Всего", ФормированиеПечатныхФорм.ФорматСумм(Сумма));
			#Вставка
			// Галфинд СадомцевСА 01.02.2024 Исправил заполнение суммы Итого в печ. форме Счет на оплату
			// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec03fe158164d
			СтруктураДанныхВсегоСкидки.Вставить("Всего", ФормированиеПечатныхФорм.ФорматСумм(Сумма-СуммаНДС));
			#КонецВставки
			ОбластьПодвалТаблицы.Параметры.Заполнить(СтруктураДанныхВсегоСкидки);
			ТабличныйДокумент.Вывести(ОбластьПодвалТаблицы);

			// Область "ПодвалТаблицыНДС"
			Если ДанныеПечати.УчитыватьНДС И НЕ ТолькоЗалогЗаТару И НЕ ДанныеПечати.ОперацияОблагаетсяНДСУПокупателя Тогда

				Для Каждого ТекСтавкаНДС Из СоответствиеСтавокНДС Цикл

					СтруктураДанныхПодвалНДС = Новый Структура;
					СтруктураДанныхПодвалНДС.Вставить("НДС", ФормированиеПечатныхФорм.ТекстНДСПоСтавке(ТекСтавкаНДС.Ключ, ДанныеПечати.ЦенаВключаетНДС));
					СтруктураДанныхПодвалНДС.Вставить("ВсегоНДС", ФормированиеПечатныхФорм.ФорматСумм(ТекСтавкаНДС.Значение, ,"-"));
					ОбластьПодвалНДС.Параметры.Заполнить(СтруктураДанныхПодвалНДС);
		#Вставка
		// Галфинд СадомцевСА 01.02.2024
		ОбластьПодвалНДС.Параметры.НДС = СтрЗаменить(ОбластьПодвалНДС.Параметры.НДС, "В т.ч.", "");
		#КонецВставки
					ТабличныйДокумент.Вывести(ОбластьПодвалНДС);

				КонецЦикла;

				СтруктураДанныхПодвалНДС = Новый Структура;
				СтруктураДанныхПодвалНДС.Вставить("ВсегоСНДС", ФормированиеПечатныхФорм.ФорматСумм(Сумма + ?(ДанныеПечати.ЦенаВключаетНДС, 0, СуммаНДС)));
				ОбластьПодвалСНДС.Параметры.Заполнить(СтруктураДанныхПодвалНДС);
				ТабличныйДокумент.Вывести(ОбластьПодвалСНДС);

			ИначеЕсли ИспользуетсяУчетНДС Тогда
				СтруктураДанныхПодвалНДС = Новый Структура;
				Если ДанныеПечати.ОперацияОблагаетсяНДСУПокупателя Тогда
					СтруктураДанныхПодвалНДС.Вставить("НДС", НСтр("ru = 'НДС исчисляется налоговым агентом';
					|en = 'VAT is calculated by tax agent'", ОбщегоНазначения.КодОсновногоЯзыка()));
				Иначе
					СтруктураДанныхПодвалНДС.Вставить("НДС", НСтр("ru = 'Без налога (НДС)';
					|en = 'Without tax (VAT)'", ОбщегоНазначения.КодОсновногоЯзыка()));
				КонецЕсли;
				СтруктураДанныхПодвалНДС.Вставить("ВсегоНДС", "-");
				ОбластьПодвалНДС.Параметры.Заполнить(СтруктураДанныхПодвалНДС);
				ТабличныйДокумент.Вывести(ОбластьПодвалНДС);
			КонецЕсли;

			// Вывести Сумму прописью
			СуммаКПрописи = Сумма + ?(ДанныеПечати.ЦенаВключаетНДС, 0, СуммаНДС);
			ИтоговаяСтрока = НСтр("ru = 'Всего наименований %Количество%, на сумму %Сумма%';
			|en = 'Total number of names %Количество% in the amount of %Сумма%'", ОбщегоНазначения.КодОсновногоЯзыка());
			ИтоговаяСтрока = СтрЗаменить(ИтоговаяСтрока, "%Количество%", НомерСтроки);
			ИтоговаяСтрока = СтрЗаменить(ИтоговаяСтрока, "%Сумма%",      ФормированиеПечатныхФорм.ФорматСумм(СуммаКПрописи, ДанныеПечати.Валюта));

			СтруктураДанныхСуммаПрописью = Новый Структура;
			Если ДанныеПечати.СчетКВозврату Тогда

				СуммаКВозврату = ДанныеПечати.СуммаКВозврату;
				СуммаИтого = СуммаКПрописи-СуммаКВозврату;
				Если СуммаИтого < 0 Тогда
					СуммаИтого = 0;
				КонецЕсли;
				СтруктураДанныхСуммаПрописью.Вставить("СуммаВозврата", ФормированиеПечатныхФорм.ФорматСумм(СуммаКВозврату, ДанныеПечати.Валюта));
				СтруктураДанныхСуммаПрописью.Вставить("СуммаИтогоКОплате", ФормированиеПечатныхФорм.ФорматСумм(СуммаИтого, ДанныеПечати.Валюта, "0"));
				СтруктураДанныхСуммаПрописью.Вставить("СуммаПрописью", РаботаСКурсамиВалютУТ.СформироватьСуммуПрописью(СуммаИтого, ДанныеПечати.Валюта));
			Иначе

				СтруктураДанныхСуммаПрописью.Вставить("СуммаПрописью", РаботаСКурсамиВалютУТ.СформироватьСуммуПрописью(СуммаКПрописи, ДанныеПечати.Валюта));
			КонецЕсли;

			СтруктураДанныхСуммаПрописью.Вставить("ИтоговаяСтрока", ИтоговаяСтрока);
			ОбластьСуммаПрописью.Параметры.Заполнить(СтруктураДанныхСуммаПрописью);
			ТабличныйДокумент.Вывести(ОбластьСуммаПрописью);
		КонецЕсли;
		ЗаполнитьРеквизитыПодвалаСчетаНаОплату(ДанныеПечати, Макет, ТабличныйДокумент, ТаблицаЭтапыОплаты, СоответствиеСтавокНДС, ПараметрыПечати);

		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, ДанныеПечати.Ссылка);

	КонецЦикла;

КонецПроцедуры

Процедура гф_ЗаполнитьТаблицуТоваров(ТаблицаТовары, СчетСсылка)
	
	Если ТипЗнч(ТаблицаТовары) <> Тип("ТаблицаЗначений") Тогда
		Возврат;	
	КонецЕсли;
	
	СтруктураПоиска = Новый Структура("Ссылка", СчетСсылка);
	Если ТаблицаТовары.НайтиСтроки(СтруктураПоиска).Количество() > 0 Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Товары.Ссылка                                                КАК Ссылка,
	|	Товары.НомерСтроки                                           КАК НомерСтроки,
	|
	//|	Товары.ВариантКомплектации.Наименование                      КАК Артикул,
	//|	Товары.ВариантКомплектации.Владелец                          КАК Номенклатура,
	//|	Товары.ВариантКомплектации.Владелец.Наименование             КАК НаименованиеПолное,
	// Галфинд СадомцевСА 01.02.2024 Заполняю Артикул в Счете на оплату
	//|	""""                                                         КАК Артикул,
	|	Товары.ВариантКомплектации.Владелец.Артикул                  КАК Артикул,
	|	ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)               КАК Номенклатура,
	|	""""                                                         КАК НаименованиеПолное,
	|	Товары.ВариантКомплектации.Упаковка                          КАК Упаковка,
	//|	Товары.ВариантКомплектации.Владелец.ЕдиницаИзмерения         КАК ЕдиницаИзмерения,
	|	Товары.ВариантКомплектации.Упаковка                          КАК ЕдиницаИзмерения,
	|
	|	Товары.Количество                                            КАК Количество,
	|	Товары.Количество                                            КАК КоличествоУпаковок,
	|	Товары.Цена                                                  КАК Цена,
	|	Товары.Сумма                                                 КАК Сумма, 
	|
	// Галфинд СадомцевСА 01.02.2024 убрал Вариант комплектации из колонки "Товары (работы, услуги)"
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec03fe158164d
	//|	Товары.ВариантКомплектации.Наименование + "" "" + Товары.ВариантКомплектации.Владелец.Наименование КАК Содержание,
	|	Товары.ВариантКомплектации.Владелец.Наименование КАК Содержание,
	|
	|	Товары.СтавкаНДС                                             КАК СтавкаНДС,
	|	Товары.СуммаНДС                                              КАК СуммаНДС,
	|
	|	0                                                            КАК СуммаСкидки,
	|	Товары.Сумма                                                 КАК СуммаБезСкидки,
	|
	|	НЕОПРЕДЕЛЕНО                                                 КАК ХозяйственнаяОперация,
	|	ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)               КАК НоменклатураНабора,
	|	ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка) КАК ХарактеристикаНабора,
	|	ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка) КАК Характеристика,
	|	ЛОЖЬ                                                         КАК ЭтоВозвратнаяТара,
	|	ЛОЖЬ                                                         КАК ЭтоНабор,
	|	ЛОЖЬ                                                         КАК ЭтоКомплектующие
	|ИЗ
	|	Документ.СчетНаОплатуКлиенту.гф_ТоварыВКоробах КАК Товары
	|ГДЕ
	|	Товары.Ссылка = &Ссылка";
	Запрос.УстановитьПараметр("Ссылка", СчетСсылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаТовары.Добавить(), Выборка);	
	КонецЦикла;
	
КонецПроцедуры

&ИзменениеИКонтроль("ЗаполнитьРеквизитыШапкиСчетаНаОплату")
Процедура гф_ЗаполнитьРеквизитыШапкиСчетаНаОплату(ДанныеПечати, Макет, ТабличныйДокумент, ТаблицаЭтапыОплаты, ТаблицаТовары)

	#Вставка
	// Галфинд СадомцевСА 01.02.2024 Расположил факсимиле рядом с подписями см. макет гф_ПФ_MXL_СчетНаОплату
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec03fe158164d
	Если Макет.ВысотаТаблицы = 0 Тогда
	#КонецВставки
	Макет = УправлениеПечатью.МакетПечатнойФормы("Обработка.ПечатьСчетовНаОплату.ПФ_MXL_СчетНаОплату");
	#Вставка
	КонецЕсли;
	#КонецВставки

	СведенияОПоставщике = ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеПечати.Организация, ДанныеПечати.Дата);

	ОбластьМакета = Макет.ПолучитьОбласть("ЗаголовокСчета");
	ФормированиеПечатныхФорм.ВывестиЛоготипВТабличныйДокумент(Макет, ОбластьМакета, "ЗаголовокСчетаЛоготип", ДанныеПечати.Организация);
	ШтрихкодированиеПечатныхФорм.ВывестиШтрихкодВТабличныйДокумент(ТабличныйДокумент, Макет, ОбластьМакета, ДанныеПечати.Ссылка);

	Если ТаблицаЭтапыОплаты.Количество() = 0 Тогда
		ДатаПлатежа = '00010101';
	ИначеЕсли ТаблицаЭтапыОплаты.Количество() = 1 Тогда
		ДатаПлатежа = ТаблицаЭтапыОплаты[0].ДатаПлатежа;
	Иначе
		ДатаПлатежа = ТаблицаЭтапыОплаты[ТаблицаЭтапыОплаты.Количество()-1].ДатаПлатежа;
	КонецЕсли;

	Если ЗначениеЗаполнено(ДатаПлатежа) Тогда
		СтруктураДанныхЗаголовок = Новый Структура;
		НадписьСрокДействия = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Счет действителен до %1.';
		|en = 'Account is valid till %1.'", ОбщегоНазначения.КодОсновногоЯзыка()), Формат(ДатаПлатежа, "ДЛФ=D")) + " ";
		#Вставка
		// Галфинд СадомцевСА 01.02.2024 Заполняю НадписьСрокДействия см. доп. реквизит Организации: Срок действия счета на оплату
		ЗаполнитьНадписьСрокДействия(ДанныеПечати.Организация, НадписьСрокДействия);
		#КонецВставки
		СтруктураДанныхЗаголовок.Вставить("СрокДействия", НадписьСрокДействия);
		ОбластьМакета.Параметры.Заполнить(СтруктураДанныхЗаголовок);
	КонецЕсли;

	ТабличныйДокумент.Вывести(ОбластьМакета);

	Если ДанныеПечати.ПлатежЗаРубеж Тогда

		ОбластьМакета = Макет.ПолучитьОбласть("ОбразецЗаполненияРеквизитыБанка");
		СтруктураДанныхШапки = Новый Структура;
		ПредставлениеПоставщикаДляПлатПоручения = "";

		Если ЗначениеЗаполнено(ДанныеПечати.БанковскийСчет) Тогда
			СтруктураДанныхШапки.Вставить("СчетБанкаПолучателяПредставление", ДанныеПечати.НомерБанковскогоСчета);
			СтруктураДанныхШапки.Вставить("БанкПолучателяПредставление", ДанныеПечати.НаименованиеБанкаМеждународное);
			Если ПустаяСтрока(СтруктураДанныхШапки.БанкПолучателяПредставление) Тогда
				СтруктураДанныхШапки.Вставить("БанкПолучателяПредставление", ДанныеПечати.НаименованиеБанка);
			КонецЕсли; 
			СтруктураДанныхШапки.Вставить("АдресБанкаПолучателяПредставление", ДанныеПечати.АдресБанка);
			СтруктураДанныхШапки.Вставить("СВИФТБанка", ДанныеПечати.СВИФТБанка);
			ПредставлениеПоставщикаДляПлатПоручения = ДанныеПечати.БанковскийСчетТекстКорреспондента;
		КонецЕсли;

		Если ПустаяСтрока(ПредставлениеПоставщикаДляПлатПоручения) Тогда
			ПредставлениеПоставщикаДляПлатПоручения = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОПоставщике, "ПолноеНаименование,");
		КонецЕсли;
		СтруктураДанныхШапки.Вставить("ПредставлениеПоставщикаДляПлатПоручения", ПредставлениеПоставщикаДляПлатПоручения);
		ОбластьМакета.Параметры.Заполнить(СтруктураДанныхШапки);
		ТабличныйДокумент.Вывести(ОбластьМакета);

		Если Не ПустаяСтрока(ДанныеПечати.НаименованиеБанкаДляРасчетовМеждународное) Тогда
			ОбластьМакета = Макет.ПолучитьОбласть("ОбразецЗаполненияРеквизитыБанкаКорреспондента");

			СтруктураДанныхШапки.Очистить();
			СтруктураДанныхШапки.Вставить("БанкКорреспондентПолучателяПредставление",
			ДанныеПечати.НаименованиеБанкаДляРасчетовМеждународное + " " + ДанныеПечати.АдресБанкаДляРасчетов);
			СтруктураДанныхШапки.Вставить("СВИФТБанкаДляРасчетов", ДанныеПечати.СВИФТБанкаДляРасчетов);
			СтруктураДанныхШапки.Вставить("СчетБанкаДляРасчетовПредставление", ДанныеПечати.СчетВБанкеДляРасчетов);

			ОбластьМакета.Параметры.Заполнить(СтруктураДанныхШапки);
			ТабличныйДокумент.Вывести(ОбластьМакета);
		КонецЕсли;

		ОбластьМакета = Макет.ПолучитьОбласть("ОбразецЗаполненияНазначениеПлатежа");
		СтруктураДанныхШапки.Очистить();
		Если Не ЗначениеЗаполнено(ДанныеПечати.НазначениеПлатежа)
			И ТипЗнч(ДанныеПечати.Ссылка) <> Тип("ДокументСсылка.СчетНаОплатуКлиенту") Тогда
			СтруктураДанныхШапки.Вставить("НазначениеПлатежа", Документы.СчетНаОплатуКлиенту.СформироватьНазначениеПлатежа(
			ДанныеПечати.Номер, ДанныеПечати.Ссылка));
		Иначе
			СтруктураДанныхШапки.Вставить("НазначениеПлатежа", ДанныеПечати.НазначениеПлатежа);
		КонецЕсли;
		ОбластьМакета.Параметры.Заполнить(СтруктураДанныхШапки);
		ТабличныйДокумент.Вывести(ОбластьМакета);

	Иначе

		Если ДанныеПечати.КонтрагентЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо
			И ЗначениеЗаполнено(ДанныеПечати.БанковскийСчет) Тогда
			ОбластьМакета = Макет.ПолучитьОбласть("ОбразецЗаполненияППСКодом");
		Иначе
			ОбластьМакета = Макет.ПолучитьОбласть("ОбразецЗаполненияПП");
		КонецЕсли;

		СтруктураДанныхШапки = Новый Структура;
		СтруктураДанныхШапки.Вставить("ИНН", СведенияОПоставщике.ИНН);
		СтруктураДанныхШапки.Вставить("КПП",СведенияОПоставщике.КПП);
		ПредставлениеПоставщикаДляПлатПоручения = "";

		СтруктураДанныхШапки.Вставить("ИдентификаторПлатежа", ДанныеПечати.ИдентификаторПлатежа);

		Если ЗначениеЗаполнено(ДанныеПечати.БанковскийСчет) Тогда

			Если ЗначениеЗаполнено(ДанныеПечати.БИКБанкаДляРасчетов) Тогда
				Банк        = ?(ЗначениеЗаполнено(ДанныеПечати.НаименованиеРКЦБанкаДляРасчетов),
				ДанныеПечати.НаименованиеРКЦБанкаДляРасчетов + "//" + ДанныеПечати.НаименованиеБанкаДляРасчетов,
				ДанныеПечати.НаименованиеБанкаДляРасчетов);
				БИК         = ДанныеПечати.БИКБанкаДляРасчетов;
				КоррСчет    = ДанныеПечати.КоррСчетБанкаДляРасчетов;
				ГородБанка  = ДанныеПечати.ГородБанкаДляРасчетов;
				НомерСчета  = ДанныеПечати.КоррСчетБанка;
			Иначе
				Банк        = ?(ЗначениеЗаполнено(ДанныеПечати.НаименованиеРКЦБанка),
				ДанныеПечати.НаименованиеРКЦБанка + "//" + ДанныеПечати.НаименованиеБанка,
				ДанныеПечати.НаименованиеБанка);
				БИК         = ДанныеПечати.БИКБанк;
				КоррСчет    = ДанныеПечати.КоррСчетБанка;
				ГородБанка  = ДанныеПечати.ГородБанка;
				НомерСчета  = ДанныеПечати.НомерБанковскогоСчета;
			КонецЕсли;

			СтруктураДанныхШапки.Вставить("БИКБанкаПолучателя", БИК);
			СтруктураДанныхШапки.Вставить("БанкПолучателя", Банк);
			СтруктураДанныхШапки.Вставить("БанкПолучателяПредставление", СокрЛП(Банк) + " " + ГородБанка);
			СтруктураДанныхШапки.Вставить("СчетБанкаПолучателя", КоррСчет);
			СтруктураДанныхШапки.Вставить("СчетБанкаПолучателяПредставление", КоррСчет);
			СтруктураДанныхШапки.Вставить("СчетПолучателяПредставление", НомерСчета);
			СтруктураДанныхШапки.Вставить("СчетПолучателя", НомерСчета);
			ПредставлениеПоставщикаДляПлатПоручения = ДанныеПечати.БанковскийСчетТекстКорреспондента;

		КонецЕсли;

		Если ПустаяСтрока(ПредставлениеПоставщикаДляПлатПоручения) Тогда
			ПредставлениеПоставщикаДляПлатПоручения = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОПоставщике, "ПолноеНаименование,");
		КонецЕсли;

		Если Не ЗначениеЗаполнено(ДанныеПечати.НазначениеПлатежа)
			И ТипЗнч(ДанныеПечати.Ссылка) <> Тип("ДокументСсылка.СчетНаОплатуКлиенту") Тогда

			СтруктураДанныхШапки.Вставить("НазначениеПлатежа", Документы.СчетНаОплатуКлиенту.СформироватьНазначениеПлатежа(
			ДанныеПечати.Номер, ДанныеПечати.Ссылка));

		Иначе

			СтруктураДанныхШапки.Вставить("НазначениеПлатежа", ДанныеПечати.НазначениеПлатежа);

		КонецЕсли;

		СтруктураДанныхШапки.Вставить("ПредставлениеПоставщикаДляПлатПоручения", ПредставлениеПоставщикаДляПлатПоручения);
		ОбластьМакета.Параметры.Заполнить(СтруктураДанныхШапки);

		Если ДанныеПечати.КонтрагентЮрФизЛицо = Перечисления.ЮрФизЛицо.ФизЛицо
			И ЗначениеЗаполнено(ДанныеПечати.БанковскийСчет) Тогда

			РеквизитыПлатежа = РеквизитыПлатежаQRКод(СтруктураДанныхШапки);
			РеквизитыПлатежа.СуммаЧислом = СуммаКОплатеПоСчету(ДанныеПечати, ТаблицаТовары);
			РеквизитыПлатежа.Ссылка = ДанныеПечати.Ссылка;

			ВывестиQRКод(РеквизитыПлатежа, ДанныеПечати, ОбластьМакета);

		КонецЕсли;

		ТабличныйДокумент.Вывести(ОбластьМакета);
	КонецЕсли;

	КолонкаКодов = ФормированиеПечатныхФорм.ДополнительнаяКолонкаПечатныхФормДокументов().ИмяКолонки;
	ВыводитьКоды = ЗначениеЗаполнено(КолонкаКодов);

	Смещать = ТипСмещенияТабличногоДокумента.ПоВертикали;
	ОбластьПервойКолонкиТоваров = Макет.Область("ПерваяКолонкаТовара");
	Если НЕ ВыводитьКоды Тогда
		ОбластьПервойКолонкиТоваров.ШиринаКолонки = ОбластьПервойКолонкиТоваров.ШиринаКолонки + Макет.Область("КолонкаКодов").ШиринаКолонки;
		Макет.УдалитьОбласть(Макет.Область("КолонкаКодов"), Смещать);
		#Вставка
	Иначе
		// Галфинд СадомцевСА 01.02.2024 Увеличил ширину колонки Артикул
		ОбластьАртикул = Макет.Область("КолонкаКодов");
		ОбластьАртикул.ШиринаКолонки = ОбластьАртикул.ШиринаКолонки + 3;
		ОбластьПервойКолонкиТоваров.ШиринаКолонки = ОбластьПервойКолонкиТоваров.ШиринаКолонки - 3;
		#КонецВставки
	КонецЕсли;

	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");

	ТекстЗаголовка = ОбщегоНазначенияУТКлиентСервер.СформироватьЗаголовокДокумента(ДанныеПечати, НСтр("ru = 'Счет на оплату';
	|en = 'Commercial invoice'", ОбщегоНазначения.КодОсновногоЯзыка()));
	СтруктураДанныхШапки = Новый Структура;
	СтруктураДанныхШапки.Вставить("ТекстЗаголовка", ТекстЗаголовка);
	ОбластьМакета.Параметры.Заполнить(СтруктураДанныхШапки);
	ТабличныйДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");

	СтруктураДанныхПоставщик = Новый Структура;
	СтруктураДанныхПоставщик.Вставить("ПредставлениеПоставщика", 
	ФормированиеПечатныхФорм.ОписаниеОрганизации(ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеПечати.ОрганизацияПоставщик, ДанныеПечати.Дата),
	"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	ОбластьМакета.Параметры.Заполнить(СтруктураДанныхПоставщик);
	ТабличныйДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	СтруктураДанныхПокупатель = Новый Структура;
	СтруктураДанныхПокупатель.Вставить("ПредставлениеПолучателя", 
	ФормированиеПечатныхФорм.ОписаниеОрганизации(ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеПечати.Контрагент, ДанныеПечати.Дата),
	"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	ОбластьМакета.Параметры.Заполнить(СтруктураДанныхПокупатель);
	ТабличныйДокумент.Вывести(ОбластьМакета);

	Если ЗначениеЗаполнено(ДанныеПечати.Грузоотправитель) Тогда
		ОбластьМакета = Макет.ПолучитьОбласть("Грузоотправитель");
		СтруктураДанныхГрузоотправитель = Новый Структура;
		СтруктураДанныхГрузоотправитель.Вставить("ПредставлениеГрузоотправителя", ОписаниеОрганизации(ДанныеПечати, "Грузоотправитель"));
		ОбластьМакета.Параметры.Заполнить(СтруктураДанныхГрузоотправитель);
		ТабличныйДокумент.Вывести(ОбластьМакета);
	КонецЕсли;

	Если ЗначениеЗаполнено(ДанныеПечати.Грузополучатель) Тогда
		ОбластьМакета = Макет.ПолучитьОбласть("Грузополучатель");
		СтруктураДанныхГрузополучатель = Новый Структура;
		СтруктураДанныхГрузополучатель.Вставить("ПредставлениеГрузополучателя", ОписаниеОрганизации(ДанныеПечати, "Грузополучатель"));
		ОбластьМакета.Параметры.Заполнить(СтруктураДанныхГрузополучатель);
		ТабличныйДокумент.Вывести(ОбластьМакета);
	КонецЕсли;

КонецПроцедуры

&ИзменениеИКонтроль("ЗаполнитьРеквизитыПодвалаСчетаНаОплату")
Процедура гф_ЗаполнитьРеквизитыПодвалаСчетаНаОплату(ДанныеПечати, Макет, ТабличныйДокумент, ТаблицаЭтапыОплаты, СоответствиеСтавокНДС, ПараметрыПечати)

	МассивПроверкиВывода = Новый Массив;

	// Вывести этапы графика оплаты
	Если ТаблицаЭтапыОплаты.Количество() > 1 Тогда

		ИмяКолонкиДатыОплаты = ?(ДанныеПечати.СчетКВозврату,
		НСтр("ru = 'Дата оплаты или возврата';
		|en = 'Date of payment or return'", ОбщегоНазначения.КодОсновногоЯзыка()),
		НСтр("ru = 'Дата оплаты';
		|en = 'Payment date'", ОбщегоНазначения.КодОсновногоЯзыка()));

		ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицыЭтапыОплаты");
		ОбластьПодвалТаблицы = Макет.ПолучитьОбласть("ИтогоЭтапыОплаты");
		СтруктураДанныхШапки = Новый Структура("ИмяКолонкиДатыОплаты",ИмяКолонкиДатыОплаты);
		ОбластьШапкаТаблицы.Параметры.Заполнить(СтруктураДанныхШапки);
		МассивПроверкиВывода.Добавить(ОбластьШапкаТаблицы);
		МассивПроверкиВывода.Добавить(ОбластьПодвалТаблицы);

		ОбластьСтрокаТаблицы = Макет.ПолучитьОбласть("СтрокаТаблицыЭтапыОплаты");

		НомерЭтапа = 1;
		Для Каждого ТекЭтап Из ТаблицаЭтапыОплаты Цикл

			ПараметрыСтроки = НовыеПараметрыСтрокиЭтапа();
			ЗаполнитьЗначенияСвойств(ПараметрыСтроки, ТекЭтап);
			ПараметрыСтроки.НомерСтроки = НомерЭтапа;
			Если Не ПараметрыСтроки.ЭтоЗалогЗаТару Тогда
				ПараметрыСтроки.ТекстНДС = ФормированиеПечатныхФорм.СформироватьТекстНДСЭтапаОплаты(
				СоответствиеСтавокНДС,
				ТекЭтап.ПроцентПлатежа);
			Иначе
				ПараметрыСтроки.ПроцентПлатежа = "-";
				ПараметрыСтроки.ТекстНДС = НСтр("ru = 'Залог за тару. Без налога (НДС).';
				|en = 'Packaging deposit. Without tax (VAT).'", ОбщегоНазначения.КодОсновногоЯзыка());
			КонецЕсли;

			ОбластьСтрокаТаблицы.Параметры.Заполнить(ПараметрыСтроки);

			МассивПроверкиВывода.Добавить(ОбластьСтрокаТаблицы);

			Если ТабличныйДокумент.ПроверитьВывод(МассивПроверкиВывода) Тогда
				Если НомерЭтапа = 1 Тогда
					ТабличныйДокумент.Вывести(ОбластьШапкаТаблицы);
					МассивПроверкиВывода.Удалить(0);
				КонецЕсли;
			Иначе
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
				ТабличныйДокумент.Вывести(ОбластьШапкаТаблицы);
			КонецЕсли;

			ТабличныйДокумент.Вывести(ОбластьСтрокаТаблицы);
			МассивПроверкиВывода.Удалить(МассивПроверкиВывода.ВГраница());

			НомерЭтапа = НомерЭтапа + 1;

		КонецЦикла;
		ТабличныйДокумент.Вывести(ОбластьПодвалТаблицы);

	КонецЕсли;

	// Вывести дополнительную информацию
	Если ЗначениеЗаполнено(ДанныеПечати.ДополнительнаяИнформация) Тогда

		Область = Макет.ПолучитьОбласть("ДополнительнаяИнформация");
		Область.Параметры.Заполнить(ДанныеПечати);
		ТабличныйДокумент.Вывести(Область);

	КонецЕсли;

	ДолжностьРуководителя = ?(ДанныеПечати.ДолжностьРуководителя = "", 
	Нстр("ru = 'Генеральный директор';
	|en = 'CEO'"), 
	ДанныеПечати.ДолжностьРуководителя);

	// Вывести подписи
	Область = Макет.ПолучитьОбласть("ПодвалСчета");
	СтруктураДанныхПодвал = Новый Структура;
	СтруктураДанныхПодвал.Вставить("ФИОРуководителя", ДанныеПечати.Руководитель);
	СтруктураДанныхПодвал.Вставить("ДолжностьРуководителя", ДолжностьРуководителя);
	СтруктураДанныхПодвал.Вставить("ФИОБухгалтера", ДанныеПечати.ГлавныйБухгалтер);
	СтруктураДанныхПодвал.Вставить("ФИОМенеджер", ФизическиеЛицаУТ.ФамилияИнициалыФизЛица(ДанныеПечати.Менеджер, ДанныеПечати.Дата));
	Область.Параметры.Заполнить(СтруктураДанныхПодвал);

	ФормированиеПечатныхФорм.ВывестиФаксимилеВТабличныйДокумент(Макет, Область, ДанныеПечати.Организация, ПараметрыПечати);
	МассивПроверкиВывода.Очистить();
	МассивПроверкиВывода.Добавить(Область);
	Если НЕ ТабличныйДокумент.ПроверитьВывод(МассивПроверкиВывода) Тогда
		ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
	КонецЕсли;
	ТабличныйДокумент.Вывести(Область);

КонецПроцедуры

Процедура ЗаполнитьНадписьСрокДействия(Организация, НадписьСрокДействия)
	// Галфинд СадомцевСА 01.02.2024
	СрокДействияСчетаРеквизит = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул",
		"гф_СрокДействияСчетаНаОплату");
	Если Не ЗначениеЗаполнено(СрокДействияСчетаРеквизит) Тогда
		Возврат;
	КонецЕсли;
	СрокДействияСчетаЗначение = УправлениеСвойствами.ЗначениеСвойства(Организация, СрокДействияСчетаРеквизит);
	Если ЗначениеЗаполнено(СрокДействияСчетаЗначение) Тогда
		НадписьСрокДействия = СрокДействияСчетаЗначение;
	КонецЕсли;

КонецПроцедуры

#КонецЕсли
