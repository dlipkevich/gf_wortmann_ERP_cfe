﻿#Область СлужебныеПроцедурыИФункции
///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаСервере
Процедура ПроверкаПередЗагрузкойНеПройдена(ТекстВыявленныхОшибок)
	//+++ БФ Бобнев К.С. 01.03.24
	Если НЕ ЗначениеЗаполнено(бф_ТипТоваров) Тогда
		Если ТекстВыявленныхОшибок <> "" Тогда
			ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + Символы.ПС;
		КонецЕсли;
		ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + "Не выбран тип товаров.";
	КонецЕсли;
	Если Объект.бф_КолонкаАртикул = 0 И бф_ТипТоваров = "Аксессуары" Тогда
		Если ТекстВыявленныхОшибок <> "" Тогда
			ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + Символы.ПС;
		КонецЕсли;
		ТекстВыявленныхОшибок = ТекстВыявленныхОшибок + "Не задана колонка артикул.";
	КонецЕсли;
	//Если Объект.КолонкаВариантКомплектации = 0 Тогда
	Если Объект.КолонкаВариантКомплектации = 0 И бф_ТипТоваров = "ТоварыВКоробах" Тогда
	//--- БФ Бобнев К.С. 01.03.24
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
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстВыявленныхОшибок);
		Возврат;
	КонецЕсли;
	
	Объект.Заказы.Очистить();
	
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Чтение данных ...");
	данные = ПрочитатьТабличныеДанные();
	//+++ БФ Бобнев К.С. 01.03.24
	Если бф_ТипТоваров = "Аксессуары" Тогда
		бф_ПроверитьАртикулыДополнитьДанные(данные);
	КонецЕсли;
	//--- БФ Бобнев К.С. 01.03.24
	//++
	Если флТестоваяЗагрузка Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Тестовая загрузка. Чтение данных завершено.");
		Возврат;
	КонецЕсли;
	//--
	
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Создание/обновление документов ...");
	
	номера = данные.Скопировать(, "Номер, Дата, КодКонтрагента, ИмяЗаказа, НомерАдресаДоставки");
	номера.Свернуть("Номер, Дата, КодКонтрагента, ИмяЗаказа, НомерАдресаДоставки");
	
	Номенклатура = Справочники.Номенклатура;
	
	Для каждого строкаНомер Из номера Цикл
		
		ЗагрузитьДанныеСтроки(строкаНомер, данные);
		
	КонецЦикла;

	ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Создание/обновление документов завершено.");
	
КонецПроцедуры

&НаСервере
Функция ПроверитьПустыеПоляПередЗагрузкой(стрНомер, стрДата)
	Если Не ЗначениеЗаполнено(стрНомер)
		ИЛИ Не ЗначениеЗаполнено(стрДата) Тогда
		СтрокаПротокола = ТЗПротокол.Добавить();
		СтрокаПротокола.Документ = "Пустые поля Номер:" + стрНомер + " Дата:" + стрДата;
		СтрокаПротокола.Комментарий = "Строки файла пропущены";
		Возврат Истина;
	КонецЕсли;
	Возврат Ложь;
КонецФункции

&НаСервере
Функция НайтиЗаказПоНомеруДате(Заказ, стрНомер, стрДата)
	Если стрНомер > "" Тогда
		Нашли = Документы.ЗаказКлиента.НайтиПоНомеру(стрНомер, стрДата);
		Если Не Нашли.Пустая() Тогда
			Если Объект.ОбновлятьДокументы Тогда
				//+++ БФ Бобнев К.С. 20.03.24
				Запрос = Новый Запрос;
				Запрос.Текст = 
					"ВЫБРАТЬ
					|	СвязанныеДокументы.Ссылка КАК Ссылка
					|ИЗ
					|	КритерийОтбора.СвязанныеДокументы(&ЗаказСсылка) КАК СвязанныеДокументы
					|ГДЕ
					|	НЕ СвязанныеДокументы.Ссылка.ПометкаУдаления";
				
				Запрос.УстановитьПараметр("ЗаказСсылка", Нашли);
				
				УстановитьПривилегированныйРежим(Истина);
				РезультатЗапроса = Запрос.Выполнить();
				УстановитьПривилегированныйРежим(Ложь);
				
				Если НЕ РезультатЗапроса.Пустой() Тогда
					СтрокаПротокола = ТЗПротокол.Добавить();
					СтрокаПротокола.Документ = Нашли;
					СтрокаПротокола.Комментарий = "По заказу уже оформлены другие документы";
					Возврат Истина;
				КонецЕсли;

				//--- БФ Бобнев К.С. 20.03.24
				Заказ = Нашли.ПолучитьОбъект();
				Заказ.гф_ТоварыВКоробах.Очистить();
				//+++ БФ Бобнев К.С. 19.03.24
				Заказ.Товары.Очистить();
				Если ЗначениеЗаполнено(стрДата) Тогда
					Заказ.Дата = стрДата;
				Иначе
					Заказ.Дата = ТекущаяДатаСеанса();
				КонецЕсли;
				//--- БФ Бобнев К.С. 19.03.24
			Иначе
				СтрокаПротокола = ТЗПротокол.Добавить();
				СтрокаПротокола.Документ = Нашли;
				СтрокаПротокола.Комментарий = "Заказ с таким номером уже существует:" + стрНомер;
				Возврат Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат Ложь;
КонецФункции

&НаСервереБезКонтекста
Функция НайтиПриоритетПоНаименованию(Наименование)
    Приоритет = Справочники.Приоритеты.ПустаяСсылка();
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Приоритеты.Ссылка КАК Ссылка
	               |ИЗ
	               |	Справочник.Приоритеты КАК Приоритеты
	               |ГДЕ
	               |	Приоритеты.Наименование = &Наименование";
	Запрос.УстановитьПараметр("Наименование", Наименование);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	КонецЕсли;
	Возврат Приоритет;
КонецФункции

&НаСервереБезКонтекста
Процедура СоздатьЗаказКлиента(Заказ, стрНомер, стрДата)
	Если Заказ = Неопределено Тогда
		Заказ = Документы.ЗаказКлиента.СоздатьДокумент();
		
		Если ЗначениеЗаполнено(стрДата) Тогда
			Заказ.Дата = стрДата;
		Иначе
			Заказ.Дата = ТекущаяДатаСеанса();
		КонецЕсли;
		
		Если стрНомер <> "" Тогда
			Заказ.Номер = стрНомер;
		Иначе
			Заказ.УстановитьНовыйНомер();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаписатьЗаказВПопытке(Заказ)
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
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеСтроки(стрНомер, данные)
		
	Если ПроверитьПустыеПоляПередЗагрузкой(стрНомер.Номер, стрНомер.Дата) Тогда
		Возврат;
	КонецЕсли;
	
	Заказ = Неопределено;
	Если НайтиЗаказПоНомеруДате(Заказ, стрНомер.Номер, стрНомер.Дата) Тогда
		Возврат;
	КонецЕсли;
		
	СоздатьЗаказКлиента(Заказ, стрНомер.Номер, стрНомер.Дата);
	Заказ.ХозяйственнаяОперация = Перечисления.ХозяйственныеОперации.РеализацияКлиенту;
	Заказ.гф_ИмяЗаказа = стрНомер.ИмяЗаказа;
	Заказ.Организация = Объект.Организация;
	Заказ.Валюта = Константы.ВалютаРегламентированногоУчета.Получить();
	Заказ.Склад = Объект.Склад;
	Заказ.НалогообложениеНДС = Перечисления.ТипыНалогообложенияНДС.ПродажаОблагаетсяНДС;
	Заказ.ЦенаВключаетНДС = Ложь;
	
	Заказ.гф_СезонныйЗаказ = Объект.СезонныйЗаказ;
	Заказ.СпособДоставки = Перечисления.СпособыДоставки.Самовывоз;
	Заказ.Статус = Перечисления.СтатусыЗаказовКлиентов.НеСогласован;
	Заказ.Приоритет = НайтиПриоритетПоНаименованию("Средний");
	Заказ.гф_ВидЦены = Объект.ВидЦены;
	
	Заказ.Партнер = Справочники.Партнеры.НайтиПоКоду(стрНомер.КодКонтрагента);
	Если Не Заказ.Партнер.Пустая() Тогда
		Заказ.Контрагент = Справочники.Контрагенты.НайтиПоРеквизиту("Партнер", Заказ.Партнер);
		Если ЗначениеЗаполнено(Заказ.Контрагент) Тогда
			Заказ.Договор = НайтиОсновнойДоговор(Заказ.Контрагент, Заказ.Организация);
		КонецЕсли;
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не найден партнер с кодом " + стрНомер.КодКонтрагента);
		СтрокаПротокола = ТЗПротокол.Добавить();
		СтрокаПротокола.Документ = "Не найден партнер с кодом " + стрНомер.КодКонтрагента;
		СтрокаПротокола.Комментарий = "";
		Возврат;
	КонецЕсли;
	
	Заказ.АдресДоставки = "";
	Заказ.гф_АдресДоставки = Справочники.гф_АдресаДоставки.ПустаяСсылка();
	Если стрНомер.НомерАдресаДоставки  > "" Тогда 
		Заказ.АдресДоставки = ПолучитьАдресДоставкиПоНомеру(стрНомер.НомерАдресаДоставки, Заказ.Контрагент);
		Заказ.гф_АдресДоставки = ПолучитьАдресДоставкиПоНомеру(стрНомер.НомерАдресаДоставки, Заказ.Контрагент);
		Если Заказ.гф_АдресДоставки.Пустая() Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не найден адрес доставки. Номер:" + стрНомер.НомерАдресаДоставки
				+ " Контрагент:" + Заказ.Контрагент);
		КонецЕсли;
	КонецЕсли;
	
	Заказ.Автор = ПараметрыСеанса.ТекущийПользователь;
	
	СтруктураПоиска = Новый Структура();
	СтруктураПоиска.Вставить("Номер", стрНомер.Номер);
	СтруктураПоиска.Вставить("Дата", стрНомер.Дата);
	СтруктураПоиска.Вставить("КодКонтрагента", стрНомер.КодКонтрагента);
	СтруктураПоиска.Вставить("ИмяЗаказа", стрНомер.ИмяЗаказа);
	СтруктураПоиска.Вставить("НомерАдресаДоставки", стрНомер.НомерАдресаДоставки);
	нашли = данные.НайтиСтроки(СтруктураПоиска);
	//+++ БФ Бобнев К.С. 01.03.24
	Если бф_ТипТоваров = "ТоварыВКоробах" Тогда
	//--- БФ Бобнев К.С. 01.03.24
		Для каждого строка Из нашли Цикл
			ДобавитьСтрокуТоварыВКоробах(Заказ, строка, Объект.ВидЦены, ТЗПротокол);
		КонецЦикла;
	//+++ БФ Бобнев К.С. 01.03.24
	ИначеЕсли бф_ТипТоваров = "Аксессуары" Тогда
		ТЗданные = данные.Скопировать(нашли);
		Если НЕ Объект.бф_ЦенаИзФайла Тогда
			бф_ЗаполнитьЦены(ТЗданные, Объект.ВидЦены, стрНомер.Дата);
		КонецЕсли;
		Для каждого строка Из ТЗданные Цикл
			бф_ДобавитьСтрокуТовары(Заказ, строка, ТЗПротокол);
		КонецЦикла;
		Заказ.СуммаДокумента = Заказ.Товары.Итог("СуммаСНДС");
	КонецЕсли;	
	//--- БФ Бобнев К.С. 01.03.24
	
	ЗаписатьЗаказВПопытке(Заказ);
	
	Объект.Заказы.Добавить().Документ = Заказ.Ссылка;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьСтрокуТоварыВКоробах(Заказ, строка, ВидЦены, ТЗПротокол)
	ЗначениеСто = 100;
	
	НоваяСтрока = Заказ.гф_ТоварыВКоробах.Добавить();
	НоваяСтрока.ВариантКомплектации = НайтиВариантКомплектации(строка.ВариантКомплектации);
	Если НоваяСтрока.ВариантКомплектации.Пустая() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не найден вариант комплектации " + строка.ВариантКомплектации);
		СтрокаПротокола = ТЗПротокол.Добавить();
		СтрокаПротокола.Документ = "Не найден вариант комплектации " + строка.ВариантКомплектации;
		СтрокаПротокола.Комментарий = "";
	Иначе
		Если ЗначениеЗаполнено(НоваяСтрока.ВариантКомплектации.Владелец) Тогда
			НоваяСтрока.СтавкаНДС = НоваяСтрока.ВариантКомплектации.Владелец.СтавкаНДС;
		КонецЕсли;
	КонецЕсли;
	НоваяСтрока.Количество = строка.Количество;
	НоваяСтрока.ВидЦены = ВидЦены;
	НоваяСтрока.ЦенаКороба = РассчитатьЦенуКороба(НоваяСтрока.ВариантКомплектации, НоваяСтрока.ВидЦены, строка.Дата);
	НоваяСтрока.ЦенаКоробаСоСкидкой = НоваяСтрока.ЦенаКороба * (1 - НоваяСтрока.Скидка / ЗначениеСто);
	НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.ЦенаКоробаСоСкидкой;
	НоваяСтрока.ВариантОбеспечения = ПредопределенноеЗначение("Перечисление.ВариантыОбеспечения.КОбеспечению");
	Ставка = 0;
	Если ЗначениеЗаполнено(НоваяСтрока.СтавкаНДС) Тогда
		Ставка = НоваяСтрока.СтавкаНДС.Ставка;
	КонецЕсли;
	НоваяСтрока.СуммаНДС = НоваяСтрока.Сумма * (Ставка / ЗначениеСто);
	НоваяСтрока.СуммаСНДС = НоваяСтрока.Сумма + НоваяСтрока.СуммаНДС;
	
	Если строка.Комментарий > "" И СтрНайти(Заказ.Комментарий, строка.Комментарий) = 0 Тогда
		Заказ.Комментарий = Заказ.Комментарий + строка.Комментарий + " ";
	КонецЕсли;
	
КонецПроцедуры

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

&НаСервере
Функция НайтиВариантКомплектации(ВариантКомплектации, НомерСтроки = 0)
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
	Если НомерСтроки <> 0 Тогда
		ДобавитьСтрокуТЗПротокол("Ошибка:" + ВариантКомплектации, "Не найден вариант комплектации", НомерСтроки)
	КонецЕсли;
	Возврат ПустаяСсылка;
КонецФункции

&НаСервере
Функция ПолучитьДату(ДатаСтрока)
	//+++ БФ Бобнев К.С. 01.03.24
	Если бф_ТипТоваров = "Аксессуары" Тогда
		массив = СтрРазделить(ДатаСтрока, ". ", Ложь);
		Если Массив.Количество() <> 3 Тогда
			Возврат Неопределено;
		КонецЕсли;
		Возврат Дата(массив[2], массив[1], массив[0]);
	ИначеЕсли бф_ТипТоваров = "ТоварыВКоробах" Тогда
	//--- БФ Бобнев К.С. 01.03.24
		массив = СтрРазделить(ДатаСтрока, "-");
		Если Массив.Количество() <> 3 Тогда
			Возврат Неопределено;
		КонецЕсли;
		Возврат Дата(массив[0], массив[1], массив[2]);
	//+++ БФ Бобнев К.С. 01.03.24
	КонецЕсли;
	//--- БФ Бобнев К.С. 01.03.24
КонецФункции

&НаСервере
Функция ПолучитьАдресДоставкиПоНомеру(НомерАдреса, Контрагент, НомерСтроки = 0)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	а.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.гф_АдресаДоставки КАК а
	|ГДЕ
	|	а.НомерАдреса ПОДОБНО &НомерАдреса + ""%""
	|	И а.Владелец = &Владелец
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ссылка
	|АВТОУПОРЯДОЧИВАНИЕ");
	Запрос.УстановитьПараметр("НомерАдреса", НомерАдреса);
	Запрос.УстановитьПараметр("Владелец", Контрагент);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
	Если НомерСтроки <> 0 Тогда
		ДобавитьСтрокуТЗПротокол("Ошибка:" + НомерАдреса + " контрагент:" + Контрагент, "Не найден адрес доставки", НомерСтроки)
	КонецЕсли;
	
	Возврат Справочники.гф_АдресаДоставки.ПустаяСсылка();
		
КонецФункции

&НаСервереБезКонтекста
Процедура РассчитатьСуммуНДСТабЧасти(СтрокаТабличнойЧасти, ДокументОбъект) Экспорт
	МетаданныеДокумента = ДокументОбъект.Метаданные();

	// Если в документе нет флагов учета НДС, то в конфигурации считается, что суммы включают НДС.
	УчитыватьНДС = ОбщегоНазначения.ПолучитьРеквизитШапки("УчитыватьНДС", ДокументОбъект, МетаданныеДокумента, Истина);
	СуммаВключаетНДС = ОбщегоНазначения.ПолучитьРеквизитШапки("СуммаВключаетНДС", ДокументОбъект, МетаданныеДокумента,
		Истина);

	СтавкаНДС = УчетНДС.ПолучитьСтавкуНДС(СтрокаТабличнойЧасти.СтавкаНДС);
	СтрокаТабличнойЧасти.СуммаНДС = УчетНДС.РассчитатьСуммуНДС(СтрокаТабличнойЧасти.Сумма,
	                                                   УчитыватьНДС, СуммаВключаетНДС, СтавкаНДС);

КонецПроцедуры

&НаСервереБезКонтекста
Процедура РассчитатьСуммуТабЧасти(СтрокаТабличнойЧасти, ДокументОбъект, СпособРасчета = Неопределено)
	ЗначениеСто = 100;

	ИмяТабличнойЧасти = ОбщегоНазначения.ПолучитьИмяТабличнойЧастиПоСсылкеНаСтроку(СтрокаТабличнойЧасти);

	МетаданныеДокумента = ДокументОбъект.Метаданные();

	Сумма = СтрокаТабличнойЧасти.Цена * СтрокаТабличнойЧасти.Количество;
	СуммаСкидки = 0;

	Если (СпособРасчета = Неопределено)
	 Или (СпособРасчета = Перечисления.СпособРасчетаСуммыДокумента.СУчетомВсехСкидок)
	 Или (СпособРасчета = Перечисления.СпособРасчетаСуммыДокумента.БезУчетаРучнойСкидки) Тогда
		Если ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("ПроцентАвтоматическихСкидок", МетаданныеДокумента,
			                                 ИмяТабличнойЧасти) Тогда
			СуммаСкидки = Сумма * СтрокаТабличнойЧасти.ПроцентАвтоматическихСкидок / ЗначениеСто;
		КонецЕсли;

		Если (СпособРасчета <> Перечисления.СпособРасчетаСуммыДокумента.БезУчетаРучнойСкидки) Тогда
			ЕстьРеквизит = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("ПроцентСкидкиНаценки", МетаданныеДокумента,
				ИмяТабличнойЧасти);
			Если ЕстьРеквизит Тогда
				СуммаСкидки = СуммаСкидки + (Сумма * СтрокаТабличнойЧасти.ПроцентСкидкиНаценки / ЗначениеСто);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	СтрокаТабличнойЧасти.Сумма = Сумма - СуммаСкидки;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьЗначениеОбласти(макет, НомерСтроки, Колонка)
	Значение = "";
	Если Колонка > 0 Тогда
		Значение = макет.Область("R" + Формат(НомерСтроки, "ЧГ=") + "C" + Формат(Колонка, "ЧГ=")).Текст;
	КонецЕсли;
	Возврат Значение;
КонецФункции

&НаСервере
Функция ПрочитатьТабличныеДанные()
	
	макет = ТабличныйДокумент;
	
	ТабДанные = Новый ТаблицаЗначений;
	Колонки = ТабДанные.Колонки;
	Колонки.Добавить("Номер", Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("Дата", Новый ОписаниеТипов("Дата"));
	Колонки.Добавить("ИмяЗаказа", Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("КодКонтрагента", Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ВариантКомплектации", Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("Количество", Новый ОписаниеТипов("Число"));
	Колонки.Добавить("Комментарий", Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("НомерАдресаДоставки", Новый ОписаниеТипов("Строка"));
	//+++ БФ Бобнев К.С. 01.03.24
	Колонки.Добавить("Артикул", Новый ОписаниеТипов("Строка"));
	//--- БФ Бобнев К.С. 01.03.24
	//+++ БФ Бобнев К.С. 19.03.24
	Если Объект.бф_ЦенаИзФайла Тогда
		Колонки.Добавить("Цена", Новый ОписаниеТипов("Число"));
	КонецЕсли;
	//--- БФ Бобнев К.С. 19.03.24
	
	НомерСтроки = Объект.ПерваяСтрокаДанныхТабличногоДокумента;
	Если НомерСтроки <= 0 Тогда
		НомерСтроки = 2;
	КонецЕсли;
	
	Пока Истина Цикл
		
		значение = макет.Область("R" + Формат(НомерСтроки, "ЧГ=") + "C1").Текст;
		Если значение = "" Тогда
			// здесь строка с пустой первой ячейкой - прекращаем загрузку данных
			Прервать;
		КонецЕсли;
		
		новая = ТабДанные.Добавить();
		
		//+++ БФ Бобнев К.С. 04.03.24
		//новая.Номер = ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.КолонкаНомер);
		новая.Номер = СокрЛП(ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.КолонкаНомер));
		//--- БФ Бобнев К.С. 04.03.24
		
		значение = ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.КолонкаДата);
		новая.Дата = ПолучитьДату(значение);

		Если Не ЗначениеЗаполнено(новая.Дата) Тогда
			ДобавитьСтрокуТЗПротокол("Ошибка:" + значение, "Неверный формат даты", НомерСтроки)
		КонецЕсли;
		
		новая.ИмяЗаказа = ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.КолонкаИмяЗаказа);
		
		новая.КодКонтрагента = ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.КолонкаКодКонтрагента);
		Партнер = Справочники.Партнеры.НайтиПоКоду(новая.КодКонтрагента);
		Контрагент = Справочники.Контрагенты.ПустаяСсылка();
		// Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба
		НайтиКонтрагентаПоПартнеру(Партнер, Контрагент, новая, НомерСтроки);
		
		//+++ БФ Бобнев К.С. 01.03.24
		Если бф_ТипТоваров = "ТоварыВКоробах" Тогда
		//--- БФ Бобнев К.С. 01.03.24
			новая.ВариантКомплектации = ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.КолонкаВариантКомплектации);
			ВариантКомплектации = НайтиВариантКомплектации(новая.ВариантКомплектации, НомерСтроки);
		//+++ БФ Бобнев К.С. 01.03.24
		ИначеЕсли бф_ТипТоваров = "Аксессуары" Тогда
			новая.Артикул = ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.бф_КолонкаАртикул);
			//Проверку существования Номенклатуры с таким Артикулом выполним вне цикла общим запросом
			//+++ БФ Бобнев К.С. 19.03.24
			Если Объект.бф_ЦенаИзФайла Тогда
				Попытка
					новая.Цена = Число(ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.бф_КолонкаЦена));
				Исключение
					ДобавитьСтрокуТЗПротокол("Ошибка:" + новая.Артикул, "Ошибка преобразования цены в число", 0)
				КонецПопытки;
			КонецЕсли;
			//--- БФ Бобнев К.С. 19.03.24
		КонецЕсли;
		//--- БФ Бобнев К.С. 01.03.24
		
		// Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба
		ЗаполнитьКоличество(новая, макет, НомерСтроки);
		
		новая.Комментарий = ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.КолонкаКомментарий);
		
		новая.НомерАдресаДоставки = ПолучитьЗначениеОбласти(макет, НомерСтроки, Объект.КолонкаНомерАдресаДоставки);
		АдресДоставки = ПолучитьАдресДоставкиПоНомеру(новая.НомерАдресаДоставки, Контрагент, НомерСтроки);
		
		НомерСтроки = НомерСтроки + 1;
		
	КонецЦикла;
	
	Возврат ТабДанные;
	
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
	//+++ БФ Бобнев К.С. 01.03.24
	Если бф_ТипТоваров = "ТоварыВКоробах" Тогда
	//--- БФ Бобнев К.С. 01.03.24
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
	//+++ БФ Бобнев К.С. 01.03.24
		Объект.бф_КолонкаАртикул = 0;
	ИначеЕсли бф_ТипТоваров = "Аксессуары" Тогда
		Объект.КолонкаНомер 				= 2;
		Объект.КолонкаДата 					= 3;
		Объект.КолонкаИмяЗаказа 			= 4;
		Объект.КолонкаКодКонтрагента 		= 5;
		Объект.КолонкаВариантКомплектации 	= 0;
		Объект.КолонкаЦенаОпт 				= 8;
		Объект.КолонкаЦенаРозница 			= 7;
		Объект.КолонкаКоличество 			= 9;
		Объект.КолонкаКомментарий 			= 0;
		Объект.КолонкаНомерАдресаДоставки 	= 10;    
		Объект.бф_КолонкаАртикул 			= 6;
	Иначе
		Объект.КолонкаНомер 				= 0;
		Объект.КолонкаДата 					= 0;
		Объект.КолонкаИмяЗаказа 			= 0;
		Объект.КолонкаКодКонтрагента 		= 0;
		Объект.КолонкаВариантКомплектации 	= 0;
		Объект.КолонкаЦенаОпт 				= 0;
		Объект.КолонкаЦенаРозница 			= 0;
		Объект.КолонкаКоличество 			= 0;
		Объект.КолонкаКомментарий 			= 0;
		Объект.КолонкаНомерАдресаДоставки 	= 0;    
		Объект.бф_КолонкаАртикул 			= 0;
	КонецЕсли;	
	//--- БФ Бобнев К.С. 01.03.24
КонецПроцедуры

&НаКлиенте
Процедура мСкладНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;   
	
	Отбор = Новый Структура;
	//+++ БФ Бобнев К.С. 04.03.24
	//Отбор.Вставить("ТоварыВКоробах", Истина);
	Отбор.Вставить("ТоварыВКоробах", бф_ТипТоваров = "ТоварыВКоробах");
	//--- БФ Бобнев К.С. 04.03.24
	ПараметрыФормы = Новый Структура("Отбор", Отбор);   
	ОткрытьФорму("Справочник.Склады.ФормаВыбора", ПараметрыФормы, Элемент, , , , ,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	Объект.Склад = ПредопределенноеЗначение("Справочник.Склады.ПустаяСсылка");
КонецПроцедуры

&НаСервере
Процедура ДобавитьСтрокуТЗПротокол(Документ, Комментарий, НомерСтроки)
	СтрокаПротокола = ТЗПротокол.Добавить();
	СтрокаПротокола.Документ = Документ;
	СтрокаПротокола.Комментарий = Комментарий;
	СтрокаПротокола.НомерСтроки = НомерСтроки;
КонецПроцедуры

#КонецОбласти

// ++ Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба

&НаСервере
Процедура НайтиКонтрагентаПоПартнеру(Партнер, Контрагент, новая, НомерСтроки)
	Если Партнер.Пустая() Тогда
		ДобавитьСтрокуТЗПротокол("Ошибка:" + новая.КодКонтрагента, "Не найден партнер по коду", НомерСтроки);
	Иначе
		Контрагент = Справочники.Контрагенты.НайтиПоРеквизиту("Партнер", Партнер);
		Если Контрагент.Пустая() Тогда
			ДобавитьСтрокуТЗПротокол("Ошибка:" + Партнер, "Не найден контрагент", НомерСтроки);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьКоличество(новая, макет, НомерСтроки)
	Если Объект.КолонкаКоличество > 0 Тогда
		значение = макет.Область("R" + Формат(НомерСтроки, "ЧГ=") + "C" + Формат(Объект.КолонкаКоличество, "ЧГ=")).Текст;
		новая.Количество = число(значение);
	Иначе
		новая.Количество = 0;
	КонецЕсли;
КонецПроцедуры

//+++ БФ Бобнев К.С. 01.03.24
&НаКлиенте
Процедура бф_ТипТоваровПриИзменении(Элемент)
	Элементы.бф_КолонкаАртикул.Видимость = (бф_ТипТоваров = "Аксессуары");
	Элементы.КолонкаАртикул.Видимость 	 = (бф_ТипТоваров = "ТоварыВКоробах");
	Элементы.бф_Цена.Видимость			 = (бф_ТипТоваров = "Аксессуары");
КонецПроцедуры

&НаСервере
Процедура бф_ПроверитьАртикулыДополнитьДанные(данные)
	ТЗ = данные.Скопировать(, "Артикул");
	ТЗ.Свернуть("Артикул");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВТ.Артикул КАК Артикул
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	&ТЗ КАК ВТ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВЫРАЗИТЬ(ВТ.Артикул КАК СТРОКА(150)) КАК Артикул,
		|	МАКСИМУМ(ЕСТЬNULL(Номенклатура.Ссылка, ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка))) КАК НоменклатураСсылка
		|ПОМЕСТИТЬ ВТ_Номенклатура
		|ИЗ
		|	ВТ КАК ВТ
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
		|		ПО ((ВЫРАЗИТЬ(ВТ.Артикул КАК СТРОКА(150))) = Номенклатура.Артикул)
		|
		|СГРУППИРОВАТЬ ПО
		|	ВЫРАЗИТЬ(ВТ.Артикул КАК СТРОКА(150))
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Номенклатура.Артикул КАК Артикул,
		|	ВТ_Номенклатура.НоменклатураСсылка КАК НоменклатураСсылка,
		|	ЕСТЬNULL(ВТ_Номенклатура.НоменклатураСсылка.СтавкаНДС, ЗНАЧЕНИЕ(Справочник.СтавкиНДС.ПустаяСсылка)) КАК СтавкаНДС,
		//+++ БФ Бобнев К.С. 19.03.24
		|	ЕСТЬNULL(СтавкиНДС.Ставка, 0) КАК СтавкаНДСЗначение
		//--- БФ Бобнев К.С. 19.03.24
		|ИЗ
		|	ВТ_Номенклатура КАК ВТ_Номенклатура
		//+++ БФ Бобнев К.С. 19.03.24
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтавкиНДС КАК СтавкиНДС
		|		ПО ЕСТЬNULL(ВТ_Номенклатура.НоменклатураСсылка.СтавкаНДС, ЗНАЧЕНИЕ(Справочник.СтавкиНДС.ПустаяСсылка)) = СтавкиНДС.Ссылка
		//--- БФ Бобнев К.С. 19.03.24
		|		
		|";
	Запрос.УстановитьПараметр("ТЗ", ТЗ);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	данные.Колонки.Добавить("НоменклатураСсылка", Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
	данные.Колонки.Добавить("СтавкаНДС", Новый ОписаниеТипов("СправочникСсылка.СтавкиНДС"));
	//+++ БФ Бобнев К.С. 19.03.24
	данные.Колонки.Добавить("СтавкаНДСЗначение", Новый ОписаниеТипов("Число"));
	//--- БФ Бобнев К.С. 19.03.24
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.НоменклатураСсылка) Тогда
			НайденныеСтроки = данные.НайтиСтроки(Новый Структура("Артикул", ВыборкаДетальныеЗаписи.Артикул));
			Для каждого Строка Из НайденныеСтроки Цикл
				//+++ БФ Бобнев К.С. 19.03.24
				//ЗаполнитьЗначенияСвойств(Строка, ВыборкаДетальныеЗаписи, "НоменклатураСсылка, СтавкаНДС");
				ЗаполнитьЗначенияСвойств(Строка, ВыборкаДетальныеЗаписи, "НоменклатураСсылка, СтавкаНДС, СтавкаНДСЗначение");
				//--- БФ Бобнев К.С. 19.03.24
			КонецЦикла;
		Иначе
			ДобавитьСтрокуТЗПротокол("Ошибка:" + ВыборкаДетальныеЗаписи.Артикул, "Не найден артикул", 0)
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура бф_ДобавитьСтрокуТовары(Заказ, строка, ТЗПротокол)
	
	НоваяСтрока = Заказ.Товары.Добавить();
	НоваяСтрока.Номенклатура = строка.НоменклатураСсылка;
	НоваяСтрока.СтавкаНДС 	 = строка.СтавкаНДС;
	НоваяСтрока.Количество 	 = строка.Количество;
	НоваяСтрока.КоличествоУпаковок 	 = строка.Количество;
	//+++ БФ Бобнев К.С. 19.03.24
	Если НЕ Объект.бф_ЦенаИзФайла Тогда
		НоваяСтрока.ВидЦены 	 = строка.ВидЦены;
	КонецЕсли; 
	//--- БФ Бобнев К.С. 19.03.24
	НоваяСтрока.ВариантОбеспечения = ПредопределенноеЗначение("Перечисление.ВариантыОбеспечения.КОбеспечению");
	НоваяСтрока.Цена		 = строка.Цена;
	НоваяСтрока.Сумма		 = строка.Количество * строка.Цена;
	НоваяСтрока.СуммаНДС 	 = ?(Заказ.ЦенаВключаетНДС, НоваяСтрока.Сумма * строка.СтавкаНДСЗначение / (100 + строка.СтавкаНДСЗначение), НоваяСтрока.Сумма * строка.СтавкаНДСЗначение / 100);
	НоваяСтрока.СуммаСНДС	 = ?(Заказ.ЦенаВключаетНДС, НоваяСтрока.Сумма, НоваяСтрока.Сумма + НоваяСтрока.СуммаНДС);
	
	Если строка.Комментарий > "" И СтрНайти(Заказ.Комментарий, строка.Комментарий) = 0 Тогда
		Заказ.Комментарий = Заказ.Комментарий + строка.Комментарий + " ";
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура бф_ЗаполнитьЦены(ТЗданные, ВидЦены, Период)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТЗданные.*
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	&ТЗданные КАК ТЗданные
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ.*,
		//|	ЕСТЬNULL(ВТ.СтавкаНДС.Ставка, 0) КАК СтавкаНДСЗначение, //--- БФ Бобнев К.С. 19.03.24
		|	ЕСТЬNULL(ЦеныНоменклатуры25СрезПоследних.Цена, 0) КАК Цена,
		|	&ВидЦены КАК ВидЦены
		|ИЗ
		|	ВТ КАК ВТ
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры25.СрезПоследних(
		|				&Период,
		|				Номенклатура В
		|						(ВЫБРАТЬ
		|							ВТ.НоменклатураСсылка КАК НоменклатураСсылка
		|						ИЗ
		|							ВТ КАК ВТ)
		|					И ВидЦены = &ВидЦены) КАК ЦеныНоменклатуры25СрезПоследних
		|		ПО ВТ.НоменклатураСсылка = ЦеныНоменклатуры25СрезПоследних.Номенклатура
		//|			И (ЕСТЬNULL(ВТ.НоменклатураСсылка.ЕдиницаИзмерения, ЗНАЧЕНИЕ(Справочник.УпаковкиЕдиницыИзмерения.ПустаяССылка)) = ЦеныНоменклатуры25СрезПоследних.УпаковкаЦО)
		|			И (ЦеныНоменклатуры25СрезПоследних.ХарактеристикаЦО = ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатурыДляЦенообразования.ПустаяСсылка))
		//|ГДЕ
		//|	НЕ ЦеныНоменклатуры25СрезПоследних.Цена ЕСТЬ NULL
		|";
	
	Запрос.УстановитьПараметр("ТЗданные", ТЗданные);
	Запрос.УстановитьПараметр("ВидЦены", ВидЦены);
	Запрос.УстановитьПараметр("Период", Период);
	
	ТЗданные = Запрос.Выполнить().Выгрузить();
	
КонецПроцедуры

//--- БФ Бобнев К.С. 01.03.24

// ++ Галфинд СадомцевСА 07.08.2023 Исправил "ошибки" СонарКуба
