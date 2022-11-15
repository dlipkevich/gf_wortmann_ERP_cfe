﻿
///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаСервере
Процедура ПроверкаПередЗагрузкойНеПройдена(ТекстВыявленныхОшибок)
	Если Объект.КолонкаВариантКомплектации = 0 Тогда
		Если ТекстВыявленныхОшибок <> "" Тогда
			ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + Символы.ПС;
		КонецЕсли;
		ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + "Не задана колонка вариант комплектации.";
	КонецЕсли;
	Если Не ЗначениеЗаполнено(Объект.Организация) Тогда
		Если ТекстВыявленныхОшибок <> "" Тогда
			ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + Символы.ПС;
		КонецЕсли;
		ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + "Не указана Организация.";
	КонецЕсли;
	Если Не ЗначениеЗаполнено(Объект.Склад) Тогда
		Если ТекстВыявленныхОшибок <> "" Тогда
			ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + Символы.ПС;
		КонецЕсли;
		ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + "Не указан Склад.";
	КонецЕсли;
	Если Не ЗначениеЗаполнено(Объект.ВидЦены) Тогда
		Если ТекстВыявленныхОшибок <> "" Тогда
			ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + Символы.ПС;
		КонецЕсли;
		ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + "Не указан Вид цены.";
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеСервер()

	ТекстВыявленныхОшибок = "";
	ПроверкаПередЗагрузкойНеПройдена(ТекстВыявленныхОшибок);
	Если ТекстВыявленныхОшибок <> "" Тогда
		Сообщить(ТекстВыявленныхОшибок);
		Возврат;
	КонецЕсли;
	
	Объект.Заказы.Очистить();
	
	сообщить("Чтение данных ...");
	данные = ПрочитатьТабличныеДанные();
	
	сообщить("Создание/обновление документов ...");
	
	номера = данные.Скопировать(, "Номер, Дата, КодКонтрагента, ИмяЗаказа, НомерАдресаДоставки");
	номера.Свернуть("Номер, Дата, КодКонтрагента, ИмяЗаказа, НомерАдресаДоставки");
	
	Номенклатура = Справочники.Номенклатура;
	
	Для каждого строкаНомер Из номера Цикл
//		ОбработкаПрерыванияПользователя();
		//состояние(строкаНомер.Номер);
		Если Не ЗначениеЗаполнено(строкаНомер.Номер)
			ИЛИ Не ЗначениеЗаполнено(строкаНомер.Дата) Тогда
			СтрокаПротокола = ТЗПротокол.Добавить();
			СтрокаПротокола.Документ = "Пустые поля Номер:" + строкаНомер.Номер + " Дата:" + строкаНомер.Дата;
			СтрокаПротокола.Комментарий = "Строки файла пропущены";
			Продолжить;
		КонецЕсли;
		
		Заказ = Неопределено;
		Если строкаНомер.Номер > "" Тогда
			Нашли = Документы.ЗаказКлиента.НайтиПоНомеру(строкаНомер.Номер, строкаНомер.Дата);
			Если не Нашли.Пустая() Тогда
				Если Объект.ОбновлятьДокументы Тогда
					Заказ = Нашли.ПолучитьОбъект();
					Заказ.гф_ТоварыВКоробах.Очистить();
				Иначе
					Продолжить;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		Если Заказ = Неопределено Тогда
			Заказ = Документы.ЗаказКлиента.СоздатьДокумент();
			
			Если ЗначениеЗаполнено(строкаНомер.Дата) Тогда
				Заказ.Дата = строкаНомер.Дата;
			Иначе
				Заказ.Дата = ТекущаяДата();
			КонецЕсли;
			
			Если строкаНомер.Номер > "" Тогда
				Заказ.Номер = строкаНомер.Номер;
			Иначе
				Заказ.УстановитьНовыйНомер();
			КонецЕсли;
		КонецЕсли;
		Заказ.ХозяйственнаяОперация = Перечисления.ХозяйственныеОперации.РеализацияКлиенту;
		Заказ.гф_ИмяЗаказа = строкаНомер.ИмяЗаказа;
		Заказ.Организация = Объект.Организация;
		Заказ.Валюта = Константы.ВалютаРегламентированногоУчета.Получить();
		Заказ.Склад = Объект.Склад;
		Заказ.НалогообложениеНДС = Перечисления.ТипыНалогообложенияНДС.ПродажаОблагаетсяНДС;
		Заказ.ЦенаВключаетНДС = Ложь;
			
		Заказ.гф_СезонныйЗаказ = Объект.СезонныйЗаказ;
		Заказ.СпособДоставки = Перечисления.СпособыДоставки.Самовывоз;
		Заказ.Статус = Перечисления.СтатусыЗаказовКлиентов.НеСогласован;
		Заказ.Приоритет = Справочники.Приоритеты.НайтиПоНаименованию("Средний");
		Заказ.гф_ВидЦены = Объект.ВидЦены;
		
		Заказ.Партнер = Справочники.Партнеры.НайтиПоКоду(строкаНомер.КодКонтрагента);
		Если не Заказ.Партнер.Пустая() Тогда
			Заказ.Контрагент = Справочники.Контрагенты.НайтиПоРеквизиту("Партнер", Заказ.Партнер);
			Если ЗначениеЗаполнено(Заказ.Контрагент) Тогда
				Заказ.Договор = НайтиОсновнойДоговор(Заказ.Контрагент, Заказ.Организация);
			КонецЕсли;
		Иначе
			сообщить("Не найден партнер с кодом " + строкаНомер.КодКонтрагента, СтатусСообщения.Важное);
			СтрокаПротокола = ТЗПротокол.Добавить();
			СтрокаПротокола.Документ = "Не найден партнер с кодом " + строкаНомер.КодКонтрагента;
			СтрокаПротокола.Комментарий = "";
			Продолжить;
		КонецЕсли;
		Если строкаНомер.НомерАдресаДоставки  > "" Тогда 
			Заказ.АдресДоставки = ПолучитьАдресДоставкиПоНомеру(строкаНомер.НомерАдресаДоставки);
		КонецЕсли;
		Заказ.Автор = ПараметрыСеанса.ТекущийПользователь;
		
		нашли = данные.НайтиСтроки(новый Структура("Номер, Дата, КодКонтрагента, ИмяЗаказа, НомерАдресаДоставки",
			строкаНомер.Номер, строкаНомер.Дата, строкаНомер.КодКонтрагента, строкаНомер.ИмяЗаказа, строкаНомер.НомерАдресаДоставки));
		Для каждого строка Из нашли Цикл
//			ОбработкаПрерыванияПользователя();
			
			НоваяСтрока = Заказ.гф_ТоварыВКоробах.Добавить();
			НоваяСтрока.ВариантКомплектации = НайтиВариантКомплектации(строка.ВариантКомплектации);
			Если НоваяСтрока.ВариантКомплектации.Пустая() Тогда
				Сообщить("Не найден вариант комплектации " + строка.ВариантКомплектации, СтатусСообщения.Важное);
				СтрокаПротокола = ТЗПротокол.Добавить();
				СтрокаПротокола.Документ = "Не найден вариант комплектации " + строка.ВариантКомплектации;
				СтрокаПротокола.Комментарий = "";
			Иначе
				Если ЗначениеЗаполнено(НоваяСтрока.ВариантКомплектации.Владелец) Тогда
					НоваяСтрока.СтавкаНДС = НоваяСтрока.ВариантКомплектации.Владелец.СтавкаНДС;
				КонецЕсли;
			КонецЕсли;
			НоваяСтрока.Количество = строка.Количество;
			НоваяСтрока.ВидЦены = Объект.ВидЦены;
			//НоваяСтрока.ЦенаКороба = строка.ЦенаОпт;
			НоваяСтрока.ЦенаКороба = РассчитатьЦенуКороба(НоваяСтрока.ВариантКомплектации, НоваяСтрока.ВидЦены, строка.Дата);
			// Скидку НЕ рассчитываем/ НЕ пересчитываем
			НоваяСтрока.ЦенаКоробаСоСкидкой = НоваяСтрока.ЦенаКороба * (1 - НоваяСтрока.Скидка/100);
			НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.ЦенаКоробаСоСкидкой;
			НоваяСтрока.ВариантОбеспечения = ПредопределенноеЗначение("Перечисление.ВариантыОбеспечения.КОбеспечению");
			Ставка = 0;
			Если ЗначениеЗаполнено(НоваяСтрока.СтавкаНДС) Тогда
				Ставка = НоваяСтрока.СтавкаНДС.Ставка;
			КонецЕсли;
			НоваяСтрока.СуммаНДС = НоваяСтрока.Сумма * (Ставка/100);
			НоваяСтрока.СуммаСНДС = НоваяСтрока.Сумма + НоваяСтрока.СуммаНДС;
			
			Если строка.Комментарий > "" и найти(Заказ.Комментарий, строка.Комментарий) = 0 Тогда
				Заказ.Комментарий = Заказ.Комментарий + строка.Комментарий + " ";
			КонецЕсли;
		КонецЦикла;
		
		Попытка
			Если Заказ.Проведен Тогда
				Заказ.Записать(РежимЗаписиДокумента.ОтменаПроведения);
			Иначе
				Заказ.Записать(РежимЗаписиДокумента.Запись);
			КонецЕсли;
			СтрокаПротокола = ТЗПротокол.Добавить();
			СтрокаПротокола.Документ = Заказ.Ссылка;
			СтрокаПротокола.Комментарий = "Записан документ";
		Исключение
			СтрокаПротокола = ТЗПротокол.Добавить();
			СтрокаПротокола.Документ = Заказ.Ссылка;
			СтрокаПротокола.Комментарий = "Ошибка при записи документа:" + ОписаниеОшибки();
		КонецПопытки;
		
		Объект.Заказы.Добавить().Документ = Заказ.Ссылка;
	КонецЦикла;

КонецПроцедуры

// ++

&НаСервереБезКонтекста
Функция РассчитатьЦенуКороба(ВариантКомплектации, ВидЦены, Период)
	Если Не ЗначениеЗаполнено(ВариантКомплектации) ИЛИ Не ЗначениеЗаполнено(ВидЦены) Тогда
		Возврат 0;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
		|	ВариантыКомплектацииНоменклатурыТовары.Номенклатура КАК Номенклатура,
		|	СУММА(ВариантыКомплектацииНоменклатурыТовары.Количество) КАК Количество
		|ИЗ
		|	Справочник.ВариантыКомплектацииНоменклатуры.Товары КАК ВариантыКомплектацииНоменклатурыТовары
		|ГДЕ
		|	ВариантыКомплектацииНоменклатурыТовары.Ссылка = &ВариантКомплектации
		|
		|СГРУППИРОВАТЬ ПО
		|	ВариантыКомплектацииНоменклатурыТовары.Номенклатура";
	Запрос.УстановитьПараметр("ВариантКомплектации", ВариантКомплектации);
	Результат = Запрос.Выполнить();
	ТЗВариантКомплектации = Результат.Выгрузить();
	Запрос.Текст = "ВЫБРАТЬ
		|	ЦеныНоменклатуры25СрезПоследних.Номенклатура КАК Номенклатура,
		|	ЦеныНоменклатуры25СрезПоследних.Цена КАК Цена
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры25.СрезПоследних(&Период,
		|			Номенклатура В (&СписокНоменклатуры)
		|				И ВидЦены = &ВидЦены) КАК ЦеныНоменклатуры25СрезПоследних";
	Запрос.УстановитьПараметр("Период", Период);
	Запрос.УстановитьПараметр("ВидЦены", ВидЦены);
	Запрос.УстановитьПараметр("СписокНоменклатуры", ТЗВариантКомплектации.ВыгрузитьКолонку("Номенклатура"));
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	ЦенаКороба = 0;
	Для Каждого СтрокаНоменклатуры Из ТЗВариантКомплектации Цикл
		СтруктураПоиска = Новый Структура("Номенклатура", СтрокаНоменклатуры.Номенклатура);
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(СтруктураПоиска) Тогда
			ЦенаКороба = ЦенаКороба + Выборка.Цена * СтрокаНоменклатуры.Количество;
		КонецЕсли;
	КонецЦикла;
	Возврат ЦенаКороба;
КонецФункции

&НаСервереБезКонтекста
Функция НайтиОсновнойДоговор(Контрагент, Организация)
	ПустаяСсылка = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ОсновнойДоговорКонтрагента.ОсновнойДоговор КАК ОсновнойДоговор
	               |ИЗ
	               |	Справочник.Контрагенты.гф_ОсновнойДоговорКонтрагента КАК ОсновнойДоговорКонтрагента
	               |ГДЕ
	               |	ОсновнойДоговорКонтрагента.Ссылка = &Контрагент
	               |	И ОсновнойДоговорКонтрагента.Организация = &Организация";
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("Организация", Организация);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ОсновнойДоговор;
	КонецЕсли;
	Возврат ПустаяСсылка;
КонецФункции

&НаСервереБезКонтекста
Функция НайтиВариантКомплектации(ВариантКомплектации)
	ПустаяСсылка = Справочники.ВариантыКомплектацииНоменклатуры.ПустаяСсылка();
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВариантыКомплектацииНоменклатуры.Ссылка КАК Ссылка,
	               |	ВариантыКомплектацииНоменклатуры.ПометкаУдаления КАК ПометкаУдаления
	               |ИЗ
	               |	Справочник.ВариантыКомплектацииНоменклатуры КАК ВариантыКомплектацииНоменклатуры
	               |ГДЕ
	               |	ВариантыКомплектацииНоменклатуры.Наименование = &Наименование
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	ПометкаУдаления";
	Запрос.УстановитьПараметр("Наименование", СокрЛП(ВариантКомплектации));
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	КонецЕсли;
	Возврат ПустаяСсылка;
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьДату(ДатаСтрока)
	
	массив = СтрРазделить(ДатаСтрока, "-");
	возврат Дата(массив[0], массив[1], массив[2])
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьАдресДоставкиПоНомеру(НомерАдреса)
	
	запрос = новый Запрос(
	"ВЫБРАТЬ
	|	а.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.гф_АдресаДоставки КАК а
	|ГДЕ
	|	а.НомерАдреса ПОДОБНО &НомерАдреса
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ссылка
	|АВТОУПОРЯДОЧИВАНИЕ");
	запрос.УстановитьПараметр("НомерАдреса", НомерАдреса);
	выборка = запрос.Выполнить().Выбрать();
	Если выборка.Следующий() Тогда
		возврат выборка.Ссылка;
	КонецЕсли;
		
КонецФункции

&НаСервереБезКонтекста
Процедура РассчитатьСуммуНДСТабЧасти(СтрокаТабличнойЧасти, ДокументОбъект) Экспорт
	МетаданныеДокумента = ДокументОбъект.Метаданные();

	// Если в документе нет флагов учета НДС, то в конфигурации считается, что суммы включают НДС.
	УчитыватьНДС = ОбщегоНазначения.ПолучитьРеквизитШапки("УчитыватьНДС", ДокументОбъект, МетаданныеДокумента, Истина);
	СуммаВключаетНДС = ОбщегоНазначения.ПолучитьРеквизитШапки("СуммаВключаетНДС", ДокументОбъект, МетаданныеДокумента, Истина);

	СтрокаТабличнойЧасти.СуммаНДС = УчетНДС.РассчитатьСуммуНДС(СтрокаТабличнойЧасти.Сумма,
	                                                   УчитыватьНДС, СуммаВключаетНДС,
	                                                   УчетНДС.ПолучитьСтавкуНДС(СтрокаТабличнойЧасти.СтавкаНДС));

КонецПроцедуры // РассчитатьСуммуНДСТабЧасти()

&НаСервереБезКонтекста
Процедура РассчитатьСуммуТабЧасти(СтрокаТабличнойЧасти, ДокументОбъект, СпособРасчета = Неопределено)

	ИмяТабличнойЧасти = ОбщегоНазначения.ПолучитьИмяТабличнойЧастиПоСсылкеНаСтроку(СтрокаТабличнойЧасти);

	МетаданныеДокумента = ДокументОбъект.Метаданные();

	Сумма = СтрокаТабличнойЧасти.Цена * СтрокаТабличнойЧасти.Количество;
	СуммаСкидки = 0;

	Если (СпособРасчета = Неопределено)
	 Или (СпособРасчета = Перечисления.СпособРасчетаСуммыДокумента.СУчетомВсехСкидок)
	 Или (СпособРасчета = Перечисления.СпособРасчетаСуммыДокумента.БезУчетаРучнойСкидки) Тогда
		Если ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("ПроцентАвтоматическихСкидок", МетаданныеДокумента,
			                                 ИмяТабличнойЧасти) Тогда
			СуммаСкидки = Сумма * СтрокаТабличнойЧасти.ПроцентАвтоматическихСкидок / 100;
		КонецЕсли;

		Если (СпособРасчета <> Перечисления.СпособРасчетаСуммыДокумента.БезУчетаРучнойСкидки)Тогда
			Если ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("ПроцентСкидкиНаценки", МетаданныеДокумента, ИмяТабличнойЧасти) Тогда
				СуммаСкидки = СуммаСкидки + (Сумма * СтрокаТабличнойЧасти.ПроцентСкидкиНаценки / 100);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	СтрокаТабличнойЧасти.Сумма = Сумма - СуммаСкидки;

КонецПроцедуры // РассчитатьСуммуТабЧасти()

&НаСервере
Функция ПрочитатьТабличныеДанные()
	
	макет = ТабличныйДокумент;
	
	таб = новый ТаблицаЗначений;
	Колонки = таб.Колонки;
	Колонки.Добавить("Номер", новый ОписаниеТипов("Строка"));
	Колонки.Добавить("Дата", новый ОписаниеТипов("Дата"));
	Колонки.Добавить("ИмяЗаказа", новый ОписаниеТипов("Строка"));
	Колонки.Добавить("КодКонтрагента", новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ВариантКомплектации", новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ЦенаОпт", новый ОписаниеТипов("Число"));
	//Колонки.Добавить("ЦенаРозница", новый ОписаниеТипов("Число"));
	Колонки.Добавить("Количество", новый ОписаниеТипов("Число"));
	Колонки.Добавить("Комментарий", новый ОписаниеТипов("Строка"));
	Колонки.Добавить("НомерАдресаДоставки", новый ОписаниеТипов("Строка"));
	
	НомерСтроки = Объект.ПерваяСтрокаДанныхТабличногоДокумента;
	Если НомерСтроки <= 0 Тогда
		НомерСтроки = 2;
	КонецЕсли;
	
	Пока Истина Цикл
//		ОбработкаПрерыванияПользователя();
		
		значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C1").Текст;
		Если значение = "" Тогда
			прервать;
		КонецЕсли;
		
		новая = таб.Добавить();
		
		Если Объект.КолонкаНомер > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаНомер,"ЧГ=")).Текст;
			новая.Номер = значение;
		КонецЕсли;
		
		Если Объект.КолонкаДата > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаДата,"ЧГ=")).Текст;
			новая.Дата = ПолучитьДату(значение);
		КонецЕсли;
		
		Если Объект.КолонкаИмяЗаказа > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаИмяЗаказа,"ЧГ=")).Текст;
			новая.ИмяЗаказа = значение;
		КонецЕсли;
		
		Если Объект.КолонкаКодКонтрагента > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаКодКонтрагента,"ЧГ=")).Текст;
			новая.КодКонтрагента = значение;
		КонецЕсли;
		
		Если Объект.КолонкаВариантКомплектации > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаВариантКомплектации,"ЧГ=")).Текст;
			новая.ВариантКомплектации = значение;
		КонецЕсли;
		
		Если Объект.КолонкаЦенаОпт > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаЦенаОпт,"ЧГ=")).Текст;
			новая.ЦенаОпт = число(значение);
		Иначе
			новая.ЦенаОпт = 0;
		КонецЕсли;
		
		//Если Объект.КолонкаЦенаРозница > 0 Тогда
		//	значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаЦенаРозница,"ЧГ=")).Текст;
		//	новая.ЦенаРозница = число(значение);
		//Иначе
		//	новая.ЦенаРозница = 0;
		//КонецЕсли;
		
		Если Объект.КолонкаКоличество > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаКоличество,"ЧГ=")).Текст;
			новая.Количество = число(значение);
		Иначе
			новая.Количество = 0;
		КонецЕсли;
		
		Если Объект.КолонкаКомментарий > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаКомментарий,"ЧГ=")).Текст;
			новая.Комментарий = значение;
		КонецЕсли;
		
		Если Объект.КолонкаНомерАдресаДоставки > 0 Тогда
			значение = макет.Область("R" + Формат(НомерСтроки,"ЧГ=") + "C" + Формат(Объект.КолонкаНомерАдресаДоставки,"ЧГ=")).Текст;
			новая.НомерАдресаДоставки = значение;
		КонецЕсли;
		
		НомерСтроки = НомерСтроки + 1;
	КонецЦикла;
	
	возврат таб;
	
КонецФункции

&НаСервере
Функция ПодготовитьТабДокНаСервере()
	
	ТабПротокол = Новый ТабличныйДокумент;
	
	ТабПротокол.АвтоМасштаб = Истина;
	ТабПротокол.ОтображатьЗаголовки = Ложь;
	ТабПротокол.ОтображатьСетку = Ложь;
	ТабПротокол.ТолькоПросмотр = Истина;
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	Макет = ОбработкаОбъект.ПолучитьМакет("Протокол");
	
	ОбластьШапка	= Макет.ПолучитьОбласть("Шапка");
	ОбластьСтрока	= Макет.ПолучитьОбласть("Строка");
	
	ТабПротокол.Вывести(ОбластьШапка);
	Для Каждого СтрокаПротокола Из ТЗПротокол Цикл
		ОбластьСтрока.Параметры.Заполнить(СтрокаПротокола);
		ТабПротокол.Вывести(ОбластьСтрока);
	КонецЦикла;
		
	Возврат ТабПротокол;
	
КонецФункции


///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД

&НаКлиенте
Процедура КомандаЗагрузить(Команда)
	
	ТЗПротокол.Очистить();
	ОчиститьСообщения();
	ЗагрузитьДанныеСервер();
	Если ТЗПротокол.Количество() > 0 Тогда
		ТабДок = ПодготовитьТабДокНаСервере();
		ТабДок.Показать("Протокол загрузки заказов");
	КонецЕсли;
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// ПРЕДОПРЕДЕЛЁННЫЕ ОБРАБОТЧИКИ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Объект.ВидЦены = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту("Ключ",	
		"гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если Объект.ПерваяСтрокаДанныхТабличногоДокумента <= 0 Тогда
		Объект.ПерваяСтрокаДанныхТабличногоДокумента = 2;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ ЭЛЕМЕНТОВ ФОРМЫ

&НаКлиенте
Процедура Установить(Команда)
	Объект.КолонкаНомер = 1;
	Объект.КолонкаДата = 2;
	Объект.КолонкаИмяЗаказа = 3;
	Объект.КолонкаКодКонтрагента = 4;
	Объект.КолонкаВариантКомплектации = 5;
	Объект.КолонкаЦенаОпт = 6;
	Объект.КолонкаЦенаРозница = 7;
	Объект.КолонкаКоличество = 8;
	Объект.КолонкаКомментарий = 9;
	Объект.КолонкаНомерАдресаДоставки = 10;
КонецПроцедуры


&НаКлиенте
Процедура мСкладНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;   
	
	Отбор = Новый Структура;
	Отбор.Вставить("ТоварыВКоробах", Истина);
	ПараметрыФормы = Новый Структура("Отбор", Отбор);   
	ОткрытьФорму("Справочник.Склады.ФормаВыбора", ПараметрыФормы, Элемент, , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца); 
КонецПроцедуры


&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	Объект.Склад = ПредопределенноеЗначение("Справочник.Склады.ПустаяСсылка");
КонецПроцедуры

